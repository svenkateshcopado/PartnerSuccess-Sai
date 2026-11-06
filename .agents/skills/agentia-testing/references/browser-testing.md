<!-- Agentia managed skill file: agentia setup skills -->

# CRT Browser Testing Reference

Use `agentia testing browser` (and the matching `agentia_testing_browser_*` MCP tools) to drive an interactive Copado Robotic Testing browser session tied to a CRT Job and Project.

## Mental Model

- **One active session at a time**, stored in `.agentia/config.user.json` under `testingBrowserSession`. Always pass `--project <project-id>` (and optional `<job-id>` / `--session-id` guards).
- **In-memory Session Cookies**: Agentia exchanges your CRT PAK for `FL`, `XSRF-TOKEN`, and `sessionsToken` cookies via `/user/access-keys/tokens?toSign=all`. Cookies stay in memory (cached with a 60s expiry buffer in long-lived processes like MCP and `recorder`) and are never written to disk.
- **Browser Viewer**: Always pass `--no-open` to `testing browser view` by default (`agentia testing browser view --project <project-id> --no-open --json`) to print/return the interactive CRT browser session URL `https://<domain>/browser/session/<sessionId>?projectId=<projectId>&orgId=<orgId>` without launching a local browser window. Omit `--no-open` only when the user explicitly asks to open the browser. `testing browser stop` cleans up the session automatically.
- **Replayable Keyword History**: Every `testing browser execute` and `testing browser recorder` event appends to `~/.agentia/testing-live/<projectId>/<jobId>.jsonl` with full Robot Framework keyword lines (`TypeSecret` values and auth tokens redacted). Closing a session does not clear history.

## Canonical Workflow

```sh
# 1. Start the session (polls /api/status, loads QWeb/QForce/QMobile, sets QWeb config, opens Chrome)
agentia testing browser start <job-id> --project <project-id> --json

# 2. (Optional) Start the recorder in a background subagent before handing the viewer URL to a user
agentia testing browser recorder --project <project-id> --output flow.robot

# 3. Surface the viewer URL with --no-open by default (omit --no-open only if the user explicitly asks to open the browser)
agentia testing browser view --project <project-id> --no-open --json

# 4. Execute Robot Framework keywords (4+ spaces separate arguments)
agentia testing browser execute --project <project-id> \
  --line "GoTo    https://example.com" \
  --line "VerifyText    Example Domain" --json

# 5. Observe page state, DOM, and annotated screenshots
agentia testing browser inspect --project <project-id> --json
agentia testing browser inspect --project <project-id> --dom --json
agentia testing browser screenshot --project <project-id> --output /tmp/page.png --json

# 6. Export proven steps from Keyword History into a .robot script
agentia testing browser history <job-id> --project <project-id> --lines-only > flow.robot

# 7. Tear down the session (cleans up host, PACE, and local state)
agentia testing browser stop --project <project-id> --yes --json
```

## Subcommands & Flags

| Subcommand | Purpose & Key Flags |
| --- | --- |
| `testing browser start <job-id>` | Create and bootstrap a session. Flags: `--project` (required), `--library QWeb\|QForce\|QMobile` (default `QWeb`), `--no-bootstrap`, `--no-browser`, `--screen WIDTHxHEIGHTxDEPTH`, `--viewport WIDTHxHEIGHT`, `--file`, `--timeout`. |
| `testing browser status [job-id]` | Check `env` (`isBrowserStarted`, `isWindowOpen`), `recorder` (`connected`), `server` (`ambleApiVersion`, `inShutdownState`, `inFatalErrorState`), and `session` (`currentIdleTime`, `sessionIdleTimeout`, `timeToExpire`, `isKeywordExecutionPending`). |
| `testing browser execute [job-id]` | Run keywords using `--line "..."` (repeatable), `--keyword <name> --arg <val>`, `--file <path>`, or `--stdin`. Pass `--raw` to skip `.robot` section parsing. |
| `testing browser inspect [job-id]` | Fetch `GET /api/system-state` (`url`, `timestamp`, `changeOrigin`, `systemState` interactive element annotations). Add `--dom` with `--output <file>` or `--json` to stream and reassemble `document.documentElement.outerHTML` over the terminal WebSocket. |
| `testing browser screenshot [job-id]` | Save the current viewport PNG (including teal detection bounding boxes) to `--output <path>`. |
| `testing browser reports [job-id]` | Fetch Robot Framework `log.html`, `report.html`, and `output.xml` metadata, or write them to `--output-dir <dir>`. |
| `testing browser set-options [job-id]` | Set the full recorder option block (`--[no-]enable`, `--[no-]scroll-text`, `--[no-]healing-context`, `--[no-]hover-text`, `--[no-]system-state`, `--[no-]verify-text`, `--[no-]table-keywords`). Unspecified options default to `false`. |
| `testing browser view` | Print (`--no-open`, default for agents) or open the CRT browser session URL. Always use `--no-open` unless the user explicitly asks to open the browser. |
| `testing browser recorder [job-id]` | Connect to the session WebSocket, enable backend recording, and stream captured interactions and executed keywords as Robot Framework lines (or JSON lines with `--json`). Flags: `--output <file.robot>`, `--no-enable`, `--force` (reclaim stale lock), `--debug`. |
| `testing browser history [job-id]` | Read per-job keyword history. Flags: `--job <id>`, `--limit <n>`, `--keyword <name>` (case-insensitive first token), `--lines-only` (flatten to raw `.robot` lines), `--include-failed` (failed executions are omitted by default), `--status completed\|failed\|recorded`. MCP `linesOnly: true` returns `count`, `jobId`, `lines`, and `projectId` without `executions`. |
| `testing browser stop [job-id]` | Stop the session on the session host and PACE, and clear local state. Requires `--yes` in `--json` / non-TTY mode (`confirm: true` in MCP). |

## Parallel Recorder & Idle Keepalive Patterns

### 1. Parallel Recorder via Background Subagent
When driving or co-piloting a browser session with a human:
1. Run `agentia testing browser start <job-id> --project <project-id> --json`.
2. Before handing the viewer URL to the user, start `agentia testing browser recorder --project <project-id> --output captured.robot` in a background shell/subagent. The recorder captures both browser interactions (`status: "recorded"`) and `testing browser execute` commands (`status: "completed"`) in execution order so `--output` produces a complete `.robot` file.
3. Run `agentia testing browser view --project <project-id> --no-open --json` (always pass `--no-open` by default unless the user explicitly asks to open the browser) and share the `url` with the user.
4. **Verify capture after the user's first action**:
   ```sh
   agentia testing browser history --project <project-id> --status recorded --json
   ```
   `recorder.connected: true` in `status` only proves the WebSocket is open, not that events are firing. If `count` remains `0` after the user clicks, drive the steps via `testing browser execute` instead.
5. **Clean shutdown**: Send `SIGINT` (`kill -INT <pid>`) to the recorder process before running `testing browser stop` so it cleanly posts `setoptions {recorder: {enabled: false}}`. Then export the unified script from history with `agentia testing browser history --project <project-id> --lines-only > captured.robot`.

### 2. Keeping Idle Sessions Warm (600s Timeout)
- `session.sessionIdleTimeout` defaults to **600 seconds (10 minutes)** and is reset **only by executed keywords**.
- The recorder's 3-second WebSocket heartbeat keeps the socket open but **does not reset the session idle timer**.
- When waiting on a human to log in (e.g., MFA/SSO) or inspect the viewer, run a lightweight keepalive loop that fires `GetTitle` every 4 minutes:
  ```sh
  while true; do sleep 240; agentia testing browser execute --project <project-id> --line "GetTitle" --json || break; done &
  ```
  Stop the keepalive loop before `testing browser stop`.

## Troubleshooting

- **`No active CRT browser session`**: Start a session with `agentia testing browser start <job-id> --project <project-id>`. If a session died from the 600s idle timeout (`404` / `410`), Agentia clears the stale local state automatically on `status` or `stop`.
- **`A CRT browser recorder is already running for session <id>`**: Another recorder holds the owner-scoped lock at `~/.agentia/testing-live/locks/<sessionId>.lock`. Stop the other process or pass `--force` if the prior process crashed.
- **Keyword fails (`CRT browser keyword execution failed`)**:
  1. Do not retry blindly. Run `agentia testing browser inspect --project <project-id> --json`.
  2. Check if the target element has `isCovered: true` (modal/sticky header blocking it) or different `readableTexts`.
  3. Check `agentia testing browser status --project <project-id> --json` to confirm `env.isWindowOpen: true` and `server.inFatalErrorState: false`.
- **Browser window closed (`isWindowOpen: false`)**: Re-open Chrome with:
  ```sh
  agentia testing browser execute --project <project-id> --line "Open Browser    about:blank    chrome" --json
  ```
