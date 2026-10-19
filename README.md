# claude-code-agents

Five Claude Code subagents: four for reviewing and verifying work, and one that audits dbt projects on Snowflake. They share one rule: agents propose and verify, a human decides and ships.

Each agent has a single job and is instructed to report what it could not prove (UNVERIFIABLE or PLAUSIBLE) instead of guessing.

## Agents

| Agent | Job | Can write files? |
|---|---|---|
| `readonly-reviewer` | Adversarial review of a named PR or diff against stated invariants. Checks live CI, not the PR body's claims. | No `Write` tool |
| `live-verifier` | Proves or disproves a claim against the running system, using an isolated browser or `curl`. Avoids paid calls by default. | Scratch files only |
| `stress-auditor` | Measures payload size, request growth and cost per action, labelling every number request or response, dev or production. | Scratch files only |
| `synth-arbiter` | Merges several independent review reports into one verdict. Settles disagreements with evidence, not votes. | No `Write` tool |
| `dbt-model-auditor` | Audits a dbt project on Snowflake: runs `dbt-project-evaluator`, then measures same-name, different-meaning columns with `sql/collision_audit.sql`. | No `Write` tool |

All five also hold `Bash`. "Read-only" here is an instruction in the agent's prompt, not a tool-level sandbox: nothing in the configuration stops a shell command from writing. Treat the agents accordingly.

## Design rules

- **A status is a claim, not evidence.** A green badge, a confident PR description and an agent's "done" are all claims until checked against the source.
- **Read-only unless stated.** The agents are told not to commit, push or edit tracked files. Scratch files go in a temporary directory outside the repo.
- **Say what could not be proven.** UNVERIFIABLE (or PLAUSIBLE, for the reviewer) is a result, not a failure.
- **Rank by value per effort.** A list of everything wrong is not a review.
- **Measure, then recommend.** `dbt-model-auditor` reports measurements and proposed names; it never renames or edits anything.

## Use

Copy the files in `.claude/agents/` into your project's `.claude/agents/` (or `~/.claude/agents/`). Run `/agents` in Claude Code to confirm they load, then invoke one by name or let Claude delegate to it.

Prerequisites:
- `readonly-reviewer`: the GitHub CLI (`gh`), authenticated.
- `live-verifier`, `stress-auditor`: the Playwright MCP server, as the Claude Code plugin (tool prefix `mcp__plugin_playwright_playwright__`) or a standalone server (`mcp__playwright__`). Without it their browser checks are reported as UNVERIFIABLE.
- `dbt-model-auditor`: the dbt CLI with a Snowflake connection. `sql/collision_audit.sql` is Snowflake SQL.

## Examples

- [`examples/collision-fixture/`](examples/collision-fixture): a synthetic fixture with known answers and three deliberate traps, for testing the collision audit. The probe and its answer key are kept in separate files.
- [`examples/agent-runs-2026-10-19.md`](examples/agent-runs-2026-10-19.md): each agent run once on a real target (a PR, a live site, a dbt project), what it found and what was checked afterwards. Start here.
- [`examples/jaffle-shop-recorded-audit.md`](examples/jaffle-shop-recorded-audit.md): what the dbt-model-auditor demo page shows for a public dbt project with two seeded defects.
- [`examples/self-review-2026-10-19.md`](examples/self-review-2026-10-19.md): an audit and a hostile review of this repo's first commit, with what was fixed.

What is not here: runs of these agents on private pull requests, any run on a Snowflake account, and any repeat run. The runs above were made by general-purpose subagents following these definition files, not through Claude Code's own agent loading.

## Related

A public demo of the same evidence-led approach applied to Snowflake and dbt: https://dbt-model-auditor.simonsangla.com

## License

MIT
