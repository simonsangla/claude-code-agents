# Fixture answer key — GRADER ONLY

**Do not send this file to the agent under test.** It is kept separate from
`fixture_probe.sql`: an agent that can read the expected answers is not being
probed, it is being prompted.

Grade the agent's returned classification against this, yourself, afterwards.

## Half 1 — the procedure (mechanical, computed by SQL)

| dim | n_a | n_b | n_shared | overlap_class |
|---|---|---|---|---|
| `country_code` | 2 | 2 | 0 | `ZERO_OVERLAP` |
| `currency_code` | 2 | 2 | 2 | `HIGH_OVERLAP` |
| `market_code` | 1 | 1 | 0 | `SINGLE_VALUE` |
| `widget_code` | 3 | 3 | 0 | `ZERO_OVERLAP` |
| `tier_code` | 3 | 2 | 2 | `SUBSET` (jaccard 0.667, containment **1.0**) |

Any deviation means the procedure is broken, not the data interesting. Known
past breakages: an unbound `SAMPLE_LIMIT` in the dynamic SQL (090904 invalid
identifier), and a session with no current schema.

## Half 2 — the agent (judgement, the actual thing under test)

| dim | Pass condition | Fail condition |
|---|---|---|
| `widget_code` | Two different dimensions; disjoint SKU sets | — |
| `currency_code` | One conformed dimension | — |
| `country_code` **TRAP 1** | UNCLEAR, or "one dimension, region split", **and** names the alternative it ruled out | Calls it a collision or homonym |
| `market_code` **TRAP 2** | Says the overlap evidence is **silent**, and moves the question to domain membership | Treats single-value-and-disjoint as **stronger** evidence of different dimensions |
| `tier_code` **TRAP 3** | Reads **containment**, sees BETA's values wholly inside ALPHA's, and calls it consistent with one shared vocabulary | Reads jaccard 0.667 as "partial, therefore suspect". Jaccard cannot see subset relationships and is the wrong statistic here |

**Why TRAP 2 exists.** A review once argued single-value-per-side made the case
for splitting stronger. It makes it weaker: two differing constants is exactly
what one conformed dimension looks like when each table is scoped to a single
member of its vocabulary — a PT-only feed beside an FI-only feed. The inference
*"a split-but-conformed dimension would still show multiple values per side"* is
a false universal, and `market_code` is the counter-example.

## Contamination note

A run in which the agent had access to this key grades **half 1 only**. The
mechanical results stay valid — SQL computes them regardless of what the agent
read — but the judgement half is void and must be re-run with the files
separated.
