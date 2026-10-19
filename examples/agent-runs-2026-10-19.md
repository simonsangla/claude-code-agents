# Running the agents on real targets, 2026-10-19

Each agent in `.claude/agents/` was run once on a real target, read-only, the day this
repo was published. How the runs were done matters: the agents were **not** loaded as
named Claude Code subagents. Each run used a general-purpose Claude Code subagent told
to read the published definition file and follow it exactly. That tests the published
instructions, not Claude Code's own agent loading. One run per agent; none of this is a
benchmark.

| Agent | Target | What it found | Checked afterwards |
|---|---|---|---|
| `readonly-reviewer` | PR #2 of this repo | Clean: 0 confirmed findings, 2 plausible and non-blocking (the workflow's glob is not recursive; tool names are not validated). It refused to call CI green because the check was still queued. | Yes: the diff and the CI state were read directly |
| `live-verifier` | the public demo site | Site is public, needs no login, shows no credential fields. The numbers on the page (8 models, 4 infos, score 88) differ from the figures this repo's example file had claimed (11, 7, 91). | Yes: the saved page text was read; the example file has been corrected |
| `stress-auditor` | the same site, production deployment | First load about 288 KB transferred in 28 requests; load event at 136 ms; brotli on; no third-party hosts; no console errors. JavaScript is 90% of the bytes. Two chunks (118 KB together) are a lead worth opening, not a measured saving. | Not independently: one sample, one network |
| `dbt-model-auditor` | the `dbt-revenue-variance-demo` project | `assert_variance_bridge_reconciles` cannot fail if an effect column is NULL (`abs(null) > 0.01` is NULL), and no `not_null` test covers `volume_effect`, `price_effect` or `total_variance`. It also flagged that `dbt-project-evaluator` is not installed. The Snowflake collision procedure could not run (no Snowflake connection) and is reported as such. | Yes: the test SQL and the model YAML were read |
| `synth-arbiter` | the four reports above | Re-verified three load-bearing claims. Confirmed the mismatch and the NULL gap, and refuted one: the dbt agent's "README drift" item was true only of an uncommitted working tree, not of the committed project. | Its three rulings were each re-read against files |

What the runs show about the agents: the reviewer and the arbiter held back claims they
could not verify, the live-verifier caught a wrong number in this repository's own
documentation, and the dbt agent found a real gap in a real test. What they do not show:
any run on a Snowflake account, any run through Claude Code's own agent loading, or any
repeat run.
