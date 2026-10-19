-- Server-side dimension collision audit. Builds DIM_COLLISION_AUDIT via
-- EXECUTE IMMEDIATE so no human ever pastes generated SQL.
-- EXECUTE AS CALLER: INFORMATION_SCHEMA reflects the caller's privileges.
-- PREREQUISITE: set a current schema first. This file uses unqualified object
-- names throughout, and a session with no default schema fails on CREATE
-- PROCEDURE and on CALL:
--     USE SCHEMA <db>.<schema>;
--     USE SECONDARY ROLES NONE;
--
-- The second line is not optional on a real run. EXECUTE AS CALLER means
-- INFORMATION_SCHEMA reflects the caller's privileges — but with SECONDARY ROLES
-- ALL (a common default for human users) those privileges are the union of every
-- role granted to the user. The audit then silently sees objects the intended
-- role cannot, widening its own scope on real data and reporting a false green
-- against the read-only guardrail.
--
-- STATUS: executed against Snowflake 2026-09-09; the fixture returns its four
-- expected classes. Every procedure variable used inside the dynamic SQL must be
-- bound with a colon (:SAMPLE_LIMIT) — a bare SAMPLE_LIMIT is parsed as a column
-- and raises 090904 invalid identifier. That bug shipped once and the fixture
-- caught it; the header had warned about quote-doubling instead, which was fine.
-- Anticipating a failure mode is not the same as covering it.

CREATE OR REPLACE PROCEDURE SP_DIM_COLLISION_AUDIT(
    TARGET_SCHEMA VARCHAR,
    SAMPLE_LIMIT  INT
)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    probe_sql VARCHAR;
    n_rows    INT;
BEGIN
    SELECT LISTAGG(
             'select ''' || column_name || ''' as dim'
          || ', ''' || ta || ''' as tbl_a'
          || ', ''' || tb || ''' as tbl_b'
          || ', ''' || dt_a || ''' as dtype_a'
          || ', ''' || dt_b || ''' as dtype_b'
          || ', (select count(*) from (select distinct to_varchar("' || column_name
             || '") v from ' || rel_a || ' where "' || column_name || '" is not null)) as n_a'
          || ', (select count(*) from (select distinct to_varchar("' || column_name
             || '") v from ' || rel_b || ' where "' || column_name || '" is not null)) as n_b'
          || ', (select count(*) from ('
             || 'select distinct to_varchar("' || column_name || '") v from ' || rel_a
             || ' where "' || column_name || '" is not null intersect '
             || 'select distinct to_varchar("' || column_name || '") v from ' || rel_b
             || ' where "' || column_name || '" is not null)) as n_shared'
          || ', (select listagg(v, '' | '') from (select distinct to_varchar("' || column_name
             || '") v from ' || rel_a || ' where "' || column_name || '" is not null limit '
             || to_varchar(:SAMPLE_LIMIT) || ')) as sample_a'
          || ', (select listagg(v, '' | '') from (select distinct to_varchar("' || column_name
             || '") v from ' || rel_b || ' where "' || column_name || '" is not null limit '
             || to_varchar(:SAMPLE_LIMIT) || ')) as sample_b'
           , ' union all ')
      INTO :probe_sql
      FROM (
        select a.column_name,
               a.table_name as ta,
               b.table_name as tb,
               a.data_type  as dt_a,
               b.data_type  as dt_b,
               '"' || a.table_schema || '"."' || a.table_name || '"' as rel_a,
               '"' || b.table_schema || '"."' || b.table_name || '"' as rel_b
        from information_schema.columns a
        join information_schema.columns b
          on  a.column_name  = b.column_name
          and a.table_schema = b.table_schema
          and a.table_name   < b.table_name
        where a.table_schema = :TARGET_SCHEMA
          and a.data_type in ('TEXT','VARCHAR','NUMBER')
          and b.data_type in ('TEXT','VARCHAR','NUMBER')
      );

    IF (probe_sql IS NULL) THEN
        RETURN 'No colliding column names found in schema ' || :TARGET_SCHEMA;
    END IF;

    EXECUTE IMMEDIATE
        'CREATE OR REPLACE TABLE DIM_COLLISION_AUDIT AS SELECT *,
            round(n_shared / nullif(n_a + n_b - n_shared, 0), 4) as jaccard,
            -- Containment, NOT jaccard, is the right statistic for a subset relationship:
            -- Jaccard is symmetric and penalises size difference, so a perfect
            -- subset of a much larger set scores near zero and reads as disjoint.
            round(n_shared / nullif(least(n_a, n_b), 0), 4) as containment,
            case when dtype_a <> dtype_b then ''TYPE_MISMATCH''
                 -- Cardinality guard, BEFORE any overlap verdict. With one distinct
                 -- value on either side, jaccard is 0 or 1 by construction and carries
                 -- no information about vocabularies. A column holding a single value
                 -- over full history is a MODELLING or LOAD question, not a naming one.
                 -- Empty is not constant. A column that is entirely NULL has no
                 -- vocabulary at all; bucketing it with a genuine constant hides
                 -- that the shared description documents a column with no data.
                 when n_a = 0 or n_b = 0 then ''NO_VALUES''
                 when n_a <= 1 or n_b <= 1 then ''SINGLE_VALUE''
                 when n_shared = 0 then ''ZERO_OVERLAP''
                 when n_shared / nullif(n_a + n_b - n_shared, 0) >= 0.90 then ''HIGH_OVERLAP''
                 -- The smaller side is (almost) wholly inside the larger: consistent
                 -- with one shared vocabulary even though jaccard is low.
                 -- Read containment, not jaccard.
                 when n_shared / nullif(least(n_a, n_b), 0) >= 0.90 then ''SUBSET''
                 else ''PARTIAL_OVERLAP'' end as overlap_class
         FROM (' || :probe_sql || ')';

    SELECT COUNT(*) INTO :n_rows FROM DIM_COLLISION_AUDIT;
    RETURN 'DIM_COLLISION_AUDIT rebuilt: ' || :n_rows || ' colliding column pairs.';
END;
$$;
