<!-- Agentia managed skill file: agentia setup skills -->

# CRT Testing Reference

Use this reference for Copado Robotic Testing commands under `agentia testing`.

## Authentication And Context

```sh
agentia auth set --crt <pak> --crt-domain <domain> --crt-org <organization-id>
agentia auth get --crt --json
```

Proceed only when the CRT credential entry reports `ready: true`. CRT commands resolve the configured CRT keychain context or supported `AGENTIA_CRT_*` process overrides. Do not pass PAKs in URLs or report them in output. Test14 is a CICD environment and is not a substitute for CRT credentials.

Use explicit `--project` and `--job` context. Agentia does not reproduce the legacy CLI's hidden active project/job selection.

## Canonical Test Workflow

1. Discover or create a project and robot.
2. Create a job/test using snapshot files or validated Git-backed storage.
3. Run through `testing job run`, which waits for the terminal build unless `--no-wait` is passed.
4. Inspect build detail, search, logs, artifacts, or xUnit.
5. Update the job or data inputs as needed.
6. Clean up regression-owned resources in reverse order with explicit confirmation.

```sh
agentia testing project list --json
agentia testing robot list --json
agentia testing job create --project <project-id> --robot <robot-id> --name "Smoke" --file tests/smoke.robot --json
agentia testing job run <job-id> --project <project-id> --json
agentia testing job runs get <build-id> --project <project-id> --job <job-id> --json
agentia testing job runs logs <build-id> --project <project-id> --job <job-id> --output ./crt.log --json
```

## Command Areas

| Area | Commands |
| --- | --- |
| Projects | `testing project list|get|create|update|delete`; `project permission list|get|set|update` |
| Robots | `testing robot list|get|create|update|delete` |
| Jobs | `testing job list|get|create|update|delete|run|refs` |
| Runs | `testing job runs list|search|get|logs|abort` |
| Job files | `testing job files list|upload|download` |
| Schedules | `testing job schedule get|set|remove` |
| Variables | `testing variable list|get|create|update|delete` |
| User parameters | `testing user-parameter list|get|create|update|delete` |
| Data tables | `testing data-table list|get|create|update|delete|export` |
| Browser testing | `testing browser start|stop|status|execute|inspect|screenshot|reports|set-options|history|view|recorder` |

`testing job` is the single namespace for test definitions and their runs. Commands directly under `job` take a job ID; `job runs get|logs|abort` take a build/run ID plus `--job`. On `testing job create` and `testing job update`, `--[no-]show-video-params` (`showVideoParams` in the API/MCP) enables or disables Video Streaming and Recording capabilities when running the test job. The older `testing create|update|status|logs|run`, `testing test ...`, `testing build ...`, and `testing job files|upload|download` forms are deprecated aliases that still execute but warn when used: `create` maps to `job create`, `update` to `job files upload` (file operations, not `job update`), `status`, `build list`, and `build latest` to `job runs list`, `build get` to `job runs get`, and `build search|logs|abort` to `job runs search|logs|abort`.

## Execution And Builds

- Runs wait for terminal build data and exit non-zero unless the final status is `succeeded`. Use `--no-wait` to return the queued run record instead.
- `--timeout` bounds waiting; `--no-exit-code` keeps a failed remote run from failing the local command when explicitly desired.
- `--save-artifacts` and `--xunit` write only to validated explicit paths. They require waiting, so they reject `--no-wait`.
- Run log output is printed live while the run executes. Pass `--no-stream-logs` for a progress spinner instead. `--json` never streams, so machine-readable output stays clean.
- Repeated `--datatable TABLE_ID:SELECTION` starts data-driven batch execution. It never waits and cannot be combined with stream, artifact-save, or xUnit modes.
- Use `job runs get`, `job runs list`, and `job runs search` instead of assuming list order.

## Schedules And Data Tables

Schedules support get, set with cron/timezone/record policy, and remove. Data tables accept CSV, TSV, JSON, and XLSX imports and support bounded preview and dataset selection. Export supports CSV, TSV, and XLSX.

Data-table create/update/delete and existing-file overwrite are protected operations. Never overwrite or delete without user intent.

## Browser Testing

Use a regression-owned job:

```sh
agentia testing browser start <job-id> --project <project-id> --json
agentia testing browser status --project <project-id> --json
agentia testing browser view --project <project-id> --no-open --json
agentia testing browser execute --project <project-id> --line "GoTo    https://example.com" --json
agentia testing browser inspect --project <project-id> --json
agentia testing browser history <job-id> --project <project-id> --lines-only
agentia testing browser stop --project <project-id> --yes --json
```

Always pass `--no-open` to `testing browser view` by default to print/return the interactive CRT browser session URL without launching a browser; omit `--no-open` only when the user explicitly asks to open the browser. Session cookies and XSRF values remain in-memory only. `recorder` is long-running and uses an owner-scoped local lock (`--force` reclaims a stale lock); neither `view` nor `recorder` is exposed through MCP. The older `testing live ...` commands remain available as deprecated aliases, except `continue` and `interrupt`, which were removed.

For deep browser-testing guidance, load:
- [browser-testing.md](browser-testing.md) — subcommands, flags, parallel recorder subagent pattern, 600s idle keepalive, and troubleshooting
- [flow-automation.md](flow-automation.md) — Observe -> Act -> Verify -> Recover loop and reading `screenshot` detection overlays with `inspect` `systemState`
- [qweb.md](qweb.md) — QWeb keyword catalog, 4+ space separator rule, and locator priority
- [qforce.md](qforce.md) — Salesforce Lightning rules (`--library QForce`, `LaunchApp`, `VerifyField`, `PickList`, `ComboBox`)

## Secret Inputs And Redaction

- Prefer `--value-stdin`/`--value-file` for variable values.
- Prefer `--git-password-stdin`/`--git-password-file` or a CRT domain credential for Git authentication.
- Sensitive variable and user-parameter values must remain redacted in human, JSON, MCP, debug, and error output.
- Validate local paths, remote paths, and Git refs before mutation.

## Confirmation

Destructive or protected CLI actions prompt in an interactive TTY. JSON and non-TTY calls require `--yes`. Matching MCP tools require `confirm: true`, not a `yes` field.

This applies to resource deletion, build abort, schedule removal, browser stop, protected data-table imports/deletion, and output overwrite.

## Gotchas

- `testing job` is a CRT test definition; `cicd job` is a Copado CICD JobExecution.
- CRT tenant users, organizations, groups, roles, licenses, and cross-region migration are intentionally not Agentia testing commands.
- Log, artifact, data-table, DOM, screenshot, and report commands may write files. Keep JSON stdout structured and report only sanitized output metadata.
