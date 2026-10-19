# Review of this repository, 2026-10-19

Two read-only reviews of this repo's first published commit, run the day it was
created. They were run by two general-purpose Claude Code subagents given an
audit prompt and a hostile-reviewer prompt. They were not run with the four agents
in `.claude/agents/`, so this shows the review format, not those agents' output.

The findings below were checked against the files before being acted on.

| Finding | Source | Checked | Status |
|---|---|---|---|
| README said "Writes to repo? No" for all four agents; two of them are granted the `Write` tool | audit, hostile | yes, frontmatter line 4 | fixed: column reworded to "scratch files only" |
| `synth-arbiter` offered to "write to the path you are told" with no `Write` tool | audit | yes, line 47 | fixed: clause removed |
| `live-verifier` cited "the secret-leak hook", which this repo does not ship | audit, hostile | yes, line 89 | fixed: now "if you run one" |
| README said every agent reports UNVERIFIABLE; `readonly-reviewer` never uses the word | audit | yes, 0 occurrences | fixed: README now says UNVERIFIABLE or PLAUSIBLE |
| "Read-only" is enforced by prompt only; all four agents hold `Bash` | audit, hostile | yes | fixed: README says so |
| Playwright tool prefix differs between the plugin and a standalone MCP install | audit, hostile | no, reported only | mitigated: both prefixes listed in `tools` |
| Four agents are generic web and PR tooling; nothing is about SQL, dbt or Snowflake | hostile | yes | addressed: added `dbt-model-auditor` agent and a SQL procedure |
| One commit, no history, no usage evidence | hostile | yes | partly open: the examples folder holds only what exists (see README) |
| Three anecdotes referenced private context a reader cannot see | hostile | yes | fixed: rewritten as general statements |

No personal, client or employer data was found in the files or the commit
metadata by either review.
