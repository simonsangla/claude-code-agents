# claude-code-agents

Four Claude Code subagents I use to review and verify work. They share one rule: agents propose and verify, a human decides and ships.

Each agent has a single job, is read-only by default, and reports what it could not prove as UNVERIFIABLE instead of guessing.

## Agents

| Agent | Job | Writes to repo? |
|---|---|---|
| `readonly-reviewer` | Adversarial review of a named PR or diff against stated invariants. Checks live CI, not the PR body's claims. | No |
| `live-verifier` | Proves or disproves a claim against the running system, using an isolated browser or `curl`. Zero paid-API spend. | No |
| `stress-auditor` | Measures payload size, request growth and cost per action, labelling every number request or response, dev or production. | No |
| `synth-arbiter` | Merges several independent review reports into one verdict. Settles disagreements with evidence, not votes. | No |

## Design rules

- **A status is a claim, not evidence.** A green badge, a confident PR description and an agent's "done" are all claims until checked against the source.
- **Read-only unless stated.** No commits, no pushes, no edits to tracked files. Scratch files go in the session scratchpad only.
- **UNVERIFIABLE is a first-class result.** If an environment, credential or fixture blocked a check, that is the finding.
- **Rank by value per effort.** A list of everything wrong is not a review.

## Use

Copy the files in `.claude/agents/` into your project's `.claude/agents/` (or `~/.claude/agents/`). Claude Code picks them up as subagents; invoke one by name or let Claude delegate to it.

`live-verifier` and `stress-auditor` use the Playwright MCP server for the browser mode. Without it, their browser checks are reported as UNVERIFIABLE.

## Related

A public demo of the same evidence-led approach applied to Snowflake and dbt: https://dbt-model-auditor.simonsangla.com

## License

MIT
