---
name: agentia-ai
description: Use this skill when prompting Copado AI agents or using interactive in-app support through the Agentia CLI or MCP, including `agentia help-agent`, `agentia ai agent ask`, `agentia ai agent chat`, Plan, Build, Test, Release, Operate, Knowledge, workspace, dialogue, user story, Salesforce org, and component context.
---

<!-- Agentia managed skill file: agentia setup skills -->

# Agentia AI

Use this skill to ask Copado AI agents through Agentia with the right agent selector, workspace context, and output mode.

Prefer the `agentia_ai_ask` MCP tool when it is available for single-turn prompts. Use CLI examples as the fallback. Use `agentia ai agent chat` only for interactive terminal sessions.

Use `agentia help-agent` when a person wants interactive Copado product support. It opens without an eager CICD credential preflight, obtains fresh short-lived access per turn, and writes response deltas immediately. Each turn refreshes bounded local context, including dominant CLI/IDE/MCP usage; follow-ups include a bounded redacted digest of successful prior messages. Successful turn pairs are retained separately for at most 24 hours but never restored into a later chat. Use `agentia history list` to inspect sanitized command outcomes or `agentia history clear --yes` to remove command and Help Agent interaction history.

## Start Here

1. For `ai agent` and workspace commands, confirm AI auth with `agentia auth get --ai --json`. Configure missing credentials with `agentia auth set --ai ...` or the supported `AGENTIA_AI_*` environment variables. For `help-agent`, confirm CICD auth with `agentia auth get --cicd --json`.
2. Omit `--agent` by default: `ask` and `chat` use `orchestrate`, which routes work to the right specialist. Pass `--agent plan`, `build`, `test`, `release`, `operate`, or `knowledge` only to target a specialist explicitly.
3. Add useful context flags when available: `--workspace`, `--dialogue`, `--user-story`, `--sf-org`, and `--component`.
4. Use `--json` for automation. Use `--no-stream` when the caller needs a buffered response.

## Reference

- Copado AI agent prompts, chat sessions, workspace context, MCP parity, and gotchas: [references/ai-agents.md](references/ai-agents.md)

## General Rules

- Keep prompts specific and include IDs or names read from Copado or the local project.
- Use the Knowledge agent for Copado AI Knowledge grounding and product questions.
- Use the Plan, Build, Test, Release, and Operate agents according to the lifecycle intent.
- Do not paste PATs or secrets into prompts.
- Use `help-agent` only in an interactive terminal; it has no JSON or MCP mode.
- Treat history as temporary diagnostic context, not an audit log. CLI/IDE command rows can contain sanitized parameters, structured results, and bounded output tails; MCP rows contain metadata only. Successful Help Agent turn pairs are redacted, bounded, and retained separately for up to 24 hours. Raw User-Agent values, secrets, full paths, conversation IDs, and HMACs are excluded.

## Report Back

Report the selected AI agent, workspace/dialogue identifiers when returned, whether the response was streamed or buffered, and any follow-up action. Do not include secrets.
