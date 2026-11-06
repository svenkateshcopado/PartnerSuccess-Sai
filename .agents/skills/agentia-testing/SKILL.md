---
name: agentia-testing
description: Use this skill when creating, updating, running, inspecting, or troubleshooting Copado Robotic Testing with the Agentia CLI, including projects, permissions, robots, jobs, builds, schedules, data tables, variables, user parameters, browser testing, Git-backed storage, and Robot Framework execution.
---

<!-- Agentia managed skill file: agentia setup skills -->

# Agentia Testing

Use this skill to operate Copado Robotic Testing through Agentia without confusing CRT resources, executions, browser sessions, and Copado CICD records.

Prefer Agentia MCP tools when they are available and match the task. Use CLI examples as the fallback, and add `--json` whenever the result will be parsed or reused.

## Start Here

1. Confirm CRT auth with `agentia auth get --crt --json`. Configure missing credentials with `agentia auth set --crt ...` or the supported `AGENTIA_CRT_*` environment variables.
2. Identify or create the CRT Project and Robot before creating or running tests. Use explicit project and job IDs; do not invent hidden active-resource defaults.
3. Use `testing job ...` as the single namespace for test definitions and runs: `job create|update|run` for definitions, `job files list|upload|download` for test files, and `job runs list|search|get|logs|abort` for executions. The old `testing create|update|status|logs|run`, `testing test ...`, `testing build ...`, and `testing job files|upload|download` forms are deprecated aliases that warn when used.
4. Never expose PAKs, session cookies, viewer keys, variable values, or generated log content that contains secrets.

## Reference

- CRT lifecycle, execution, schedules, data tables, browser testing, and safety rules: [references/tests.md](references/tests.md)
- Browser session lifecycle, parallel recorder subagent workflow, 600s idle keepalive, and troubleshooting: [references/browser-testing.md](references/browser-testing.md)
- Goal-driven browser-testing automation loop (Observe -> Act -> Verify -> Recover), screenshot detection overlays, and script export: [references/flow-automation.md](references/flow-automation.md)
- QWeb Robot Framework keyword catalog, 4-space separator rule, locator priority, and decision tree: [references/qweb.md](references/qweb.md)
- QForce & Salesforce Lightning automation (`--library QForce`, `LaunchApp`, `VerifyField`, `PickList`, `ComboBox`): [references/qforce.md](references/qforce.md)

## General Rules

- `agentia testing job run` starts CRT Robot Framework execution. It is different from `agentia cicd work test --local`.
- `agentia testing job` manages CRT job/test definitions. It is different from `agentia cicd job`, which manages Copado CICD JobExecution records.
- `testing job run` waits for the final build result and exits non-zero when it fails. Add `--no-wait` when only the queued run record is needed.
- Use Git-backed job flags only when the user or project clearly uses repository-backed CRT test storage.
- In JSON or non-interactive CLI calls, destructive actions require `--yes`; matching MCP tools require `confirm: true`.
- Prefer `--value-stdin` and `--git-password-stdin` over putting secrets in process arguments.
- Always pass `--no-open` to `agentia testing browser view` by default (`agentia testing browser view --project <project-id> --no-open --json`) and share the returned URL; omit `--no-open` only when the user explicitly asks to open the browser.
- Use the currently configured CRT credential context for validation. Test14 credentials belong to CICD and must not be substituted for CRT credentials.

## Report Back

Report the CRT project, robot, job/test ID, build or browser-session ID when present, final status, cleanup, and where outputs were written. Do not include PAKs or other secrets.
