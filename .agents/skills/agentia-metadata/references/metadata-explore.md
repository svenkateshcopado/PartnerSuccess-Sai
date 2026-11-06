<!-- Agentia managed skill file: agentia setup skills -->

# Org Intelligence — Metadata Explore Reference

**Org Intelligence** is Agentia’s read-only Salesforce metadata inspection
feature: `agentia cicd metadata explore` and MCP `agentia_metadata_explore`
call `POST /agentia/headless/ai_metadata_tool` against the user's connected
sandbox/developer org (Copado credential or Salesforce session).

This is **org Metadata API exploration**, not Copado’s metadata index
(`cicd metadata list`) or content compare helpers.

**Source priority:** local project files first (when present), then the org.

**Can:** read / list / search / describe metadata; `find_references`; run
specified Apex tests when asked.

**Cannot:** read org **data** (records); **edit**, create, update, validate, or
deploy metadata. Do not invent validate/deploy/create/update, `check_async_id`,
or flags such as `--metadata-files`, `--async-id`, `--test-level`,
`--validate-only`, or `--organization-name`.

## Prerequisites

```sh
agentia auth get --cicd --json
```

Omitting `--credential-id` / `credentialId` uses the CICD project default
credential automatically. Override only when the user needs a different org.
Credential auth and `--session-id` + `--endpoint` are mutually exclusive.

```sh
agentia cicd project default set --credential <credential-id>
agentia cicd environment list --type Sandbox --json
agentia cicd credential list --environmentid <environment-id> --json
```

## Shell Quoting

Always quote CLI wildcards:

```sh
agentia cicd metadata explore --action list --object-type ApexClass --pattern 'Account*' --json
```

MCP `pattern` does not need shell quotes.

## CLI Flags / MCP Args

| CLI | MCP | Notes |
| --- | --- | --- |
| `--action` | `action` | Required. `list`, `search`, `read_documentation`, `describe_type`, `read`, `find_references`, `run_apex_tests` |
| `--object-type` | `objectType` | e.g. `ApexClass`, `CustomObject`, `Flow` |
| `--full-name` | `fullName` | Required for `read` |
| `--pattern` | `pattern` | Default `*`; quote wildcards on CLI |
| `--apex-unit-tests` | `apexUnitTests` | Required for `run_apex_tests` |
| `--credential-id` | `credentialId` | Overrides project default |
| `--session-id` | `sessionId` | With `--endpoint` only; never log |
| `--endpoint` | `endpoint` | Salesforce instance URL with session |
| `--json` | — | `{ output, credentialId? }` plus experimental warning |

## Actions

### `list`

List names for one metadata type. Use returned `fullName` values with `read`.

```sh
agentia cicd metadata explore --action list --object-type CustomObject --pattern 'Account*' --json
```

Special pattern rules:

- **CustomField / FieldSet / DuplicateRule / ListView** — pattern must start with
  SObject + `.` (e.g. `Account.Name`, `Account.namespace__Name__c`).
- **Flow** — pattern matches API name, label, and triggering object API name.

Unsupported listings: **Reports**, **Dashboards**, **Folders** — tell the user.

### `search`

Text search across **ApexPage, ApexClass, ApexTrigger, ApexComponent** only.
Pattern ≥ 2 characters; at most one `*`.

```sh
agentia cicd metadata explore --action search --pattern 'MyCtrl*' --json
```

### `describe_type` / `read_documentation`

Type shape vs tool-provided docs. Prefer `describe_type` for compact structure.

```sh
agentia cicd metadata explore --action describe_type --object-type Flow --json
agentia cicd metadata explore --action read_documentation --object-type ApexClass --json
```

### `read`

Retrieve one component. **Profile contents are not supported**—inform the user
you cannot answer questions about Profile body/details.

```sh
agentia cicd metadata explore --action read --object-type ApexClass --full-name ns__MyClass --json
```

### `find_references`

Partial **org** reference lookup: metadata that uses or calls a given item via
the Metadata API tool. Requires `--object-type` and `--full-name`. Coverage may
be incomplete—treat results as a starting point.

For the **Copado CICD dependency graph** (including local DX `--path`), use
`cicd metadata dependency list` instead—see
[metadata-dependency.md](metadata-dependency.md).

```sh
agentia cicd metadata explore --action find_references --object-type ApexClass --full-name MyClass --json
```

### `run_apex_tests`

Requires explicit test class names. Cannot run all tests or local tests—ask the
user which classes to run.

```sh
agentia cicd metadata explore --action run_apex_tests --apex-unit-tests MyClassTest --json
```

## Limits And Behavior

- Selected metadata access only—no org compare, no mass structure scan.
- Truncated/incomplete lists → narrow pattern or tell the user the scan is too broad.
- Tool returns YAML in `output`; **user-facing replies should be XML**, not YAML.
- Never echo `--session-id` or other secrets.

## Related Commands

| Need | Command |
| --- | --- |
| Org Metadata API explore (read-oriented) | `cicd metadata explore` |
| Copado metadata index search | `cicd metadata list` |
| Indexed/Git content blobs | `cicd metadata content get` |
| Org/Git content diff | `cicd metadata content compare` |
| Copado dependency graph (local DX `--path`, story/defaults context) | `cicd metadata dependency list` — [metadata-dependency.md](metadata-dependency.md) |
