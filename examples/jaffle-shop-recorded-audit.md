# Recorded audit: dbt-labs/jaffle-shop-classic

A real run, not a mock-up, recorded on 2026-09-26 by the dbt-model-auditor demo
(https://dbt-model-auditor.simonsangla.com). The demo is a web app that reads a
dbt project and its Snowflake `INFORMATION_SCHEMA`; the `dbt-model-auditor` agent
in this repo is a separate, read-only counterpart. This file records what the demo
returned, not what the agent returned.

Target: the public `dbt-labs/jaffle-shop-classic` project, commit `fd7bfac`, dbt
1.12.2, loaded into a throwaway Snowflake database. Two defects were seeded on
purpose, so the audit had known answers to find:

| Seeded defect | What it simulates |
|---|---|
| `stg_refunds` builds with 0 rows | A staging model that runs green and carries no data |
| `customer_ltv` has no tests and no docs, and reads a raw source directly | An undocumented mart bypassing staging |

Recorded result:

| Measure | Value |
|---|---|
| Models audited | 11 |
| Errors | 1 |
| Warnings | 0 |
| Infos | 7 |
| Score | 91 |

Checks that ran: `empty-model`, `stale-model`, `missing-clustering`,
`recent-failure`, `slow-query`, `no-primary-key`.

The snapshot is stored in the demo repository as `lib/audit-snapshot.json` and can
be regenerated with its recording script; it is never edited by hand. That
repository is not public, so the numbers above are not independently checkable
from this one.
