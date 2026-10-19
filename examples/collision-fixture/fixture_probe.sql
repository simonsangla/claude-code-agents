-- Capability probe — RUNNER FILE. Synthetic data only.
--
-- THE ANSWER KEY IS NOT IN THIS FILE, DELIBERATELY.
-- It lives in fixture_expected.md, which must NOT be given to the agent under
-- test. A probe whose runner can read the answers measures nothing.
--
-- Dispatch: hand this file to the agent, ask for raw output plus its own
-- meaning-classification of each row. Grade against fixture_expected.md
-- yourself, afterwards.

CREATE SCHEMA IF NOT EXISTS DIM_AUDIT_FIXTURE;
USE SCHEMA DIM_AUDIT_FIXTURE;   -- required: object names below are unqualified

-- Least-privilege honesty. With SECONDARY ROLES ALL (a common default) the
-- session's effective privileges are the union of every role granted to the
-- user, so an audit can silently see objects the intended role cannot — a
-- false green, and on a real run a silent widening of scope.
USE SECONDARY ROLES NONE;

CREATE OR REPLACE TABLE DIM_AUDIT_FIXTURE.FIXTURE_ALPHA AS
SELECT column1::varchar AS widget_code,
       column2::varchar AS currency_code,
       column3::varchar AS country_code,
       column4::varchar AS market_code,
       column5::varchar AS tier_code
FROM VALUES ('AAA','EUR','PT','PT','T1'), ('BBB','EUR','PT','PT','T2'),
            ('CCC','GBP','ES','PT','T3');

CREATE OR REPLACE TABLE DIM_AUDIT_FIXTURE.FIXTURE_BETA AS
SELECT column1::varchar AS widget_code,
       column2::varchar AS currency_code,
       column3::varchar AS country_code,
       column4::varchar AS market_code,
       column5::varchar AS tier_code
FROM VALUES ('X-1','EUR','FI','FI','T1'), ('X-2','GBP','SE','FI','T1'),
            ('X-3','GBP','FI','FI','T2');

CALL SP_DIM_COLLISION_AUDIT('DIM_AUDIT_FIXTURE', 20);
SELECT * FROM DIM_COLLISION_AUDIT ORDER BY dim;

-- Report the raw table, then classify what each row MEANS in your own words,
-- stating for each what you ruled out and with which query.
--
-- Clean up:  DROP SCHEMA DIM_AUDIT_FIXTURE;
