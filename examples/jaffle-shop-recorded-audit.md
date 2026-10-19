# Recorded audit: dbt-labs/jaffle-shop-classic

A recorded run of the dbt-model-auditor demo (https://dbt-model-auditor.simonsangla.com),
read from the live page on 2026-10-19. The demo is a web app that reads a dbt project
and its Snowflake `INFORMATION_SCHEMA`; the `dbt-model-auditor` agent in this repo is a
separate, read-only counterpart. This file records what the demo shows, not what the
agent returned.

Target: the public `dbt-labs/jaffle-shop-classic` project at commit `fd7bfac`, audited
on Snowflake on 2026-09-26 and replayed on the page by the current audit engine. The
page states that viewing it runs no query. Two defects were added on purpose, so the
audit had known answers to find:

| Seeded defect | What it simulates |
|---|---|
| `stg_refunds` builds with 0 rows | A staging model that runs green and carries no data |
| `customer_ltv` has no tests and no docs, and reads a raw source directly | An undocumented mart bypassing staging |

What the page shows (read 2026-10-19):

| Measure | Value |
|---|---|
| Models evaluated | 8 |
| Test coverage | 63% (5 of 8) |
| Doc coverage | 25% (2 of 8) |
| Audit score | 88 |
| Errors | 1 (`empty-model` on `STG_REFUNDS`, 0 rows) |
| Warnings | 0 |
| Infos | 4 (`no-primary-key` on `CUSTOMERS`, `CUSTOMER_LTV`, `ORDERS`, `STG_REFUNDS`) |

Six checks ran, none failed to run.

An earlier version of this file listed 11 models, 7 infos and a score of 91. Those
figures came from a stored snapshot in the demo's source, not from the page, and did
not match what a visitor sees. An independent read of the live page caught it (see
[`agent-runs-2026-10-19.md`](agent-runs-2026-10-19.md)). The page can change when its
audit engine changes, so re-read it before quoting these numbers. The demo's source
repository is not public.
