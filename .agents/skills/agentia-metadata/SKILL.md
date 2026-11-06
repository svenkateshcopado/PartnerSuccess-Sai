---
name: agentia-metadata
description: Org Intelligence — read Salesforce metadata in a sandbox or developer org through Agentia `cicd metadata explore` (and MCP `agentia_metadata_explore`). Use when listing or searching metadata names, reading items by API name, finding where a class/field/etc is referenced, describing types, reading type documentation, or running specified Apex tests. Also covers Copado `cicd metadata dependency list` (MCP `agentia_metadata_dependency_list`), including `--path` for local DX files. Prefer local project files first, then the org. Reads metadata only (not org data); does not edit or deploy metadata.
---

<!-- Agentia managed skill file: agentia setup skills -->

# Org Intelligence (Agentia Metadata Exploration)

**Org Intelligence** lets you inspect Salesforce **metadata** in the user's
connected sandbox / developer org via `cicd metadata explore` (MCP
`agentia_metadata_explore`). Prefer MCP when available; otherwise use the CLI
with `--json` when results will be parsed.

Covers Apex classes, triggers, objects, fields, Flows, and other Metadata API
types. First release is **read-oriented** only—do not invent validate, deploy,
create, update, or `check_async_id`.

## Capabilities And Limits

| Can | Cannot |
| --- | --- |
| Read / list / search / describe **metadata** | Read or query **org data** (records, SOQL results, reports as data) |
| Find metadata references (`find_references`) | **Edit**, create, update, validate, or deploy metadata |
| Run specified Apex test classes (when asked) | Mass-scan or compare entire orgs |

If the user asks to change metadata or fetch record data, say Org Intelligence
cannot do that and point them at the appropriate Copado/Agentia workflow or
local editing instead.

## Source Priority

1. **Local project files first** (workspace / git / force-app / retrieved source)
   when they exist and answer the question.
2. **Then the connected org** via Org Intelligence (`cicd metadata explore`)
   for names, bodies, docs, and references that are missing or unclear locally.

Do not call the org when local files already provide a clear answer. Prefer
local when reconciling differences unless the user asks for the org version.

## What You Can Do

| Goal | Action |
| --- | --- |
| List metadata names that match a pattern | `list` |
| Search source (Apex Page/Class/Trigger/Component only) | `search` |
| Retrieve one item by API name | `read` |
| Find where a class/field/etc is used or called (org) | `find_references` |
| Copado dependency graph (pipeline/org; local DX `--path`) | `cicd metadata dependency list` |
| Describe a metadata type shape | `describe_type` |
| Get type documentation from the tool | `read_documentation` |
| Run specific Apex test classes | `run_apex_tests` |

Use `list` / `search` to discover exact names before `read` or
`find_references`. Pass type + name for references. Confirm with the user
before `run_apex_tests`. For Copado uses/dependants from a local DX file,
prefer `cicd metadata dependency list --path` (see dependency reference)—do
not invent type/name when a path is available.

## Org And Scope

- Target is the CICD project default credential when `--credential-id` /
  `credentialId` is omitted. Pass `--credential-id` only to override. Do not
  mix credential auth with `--session-id` + `--endpoint`.
- The user may call this **Org Intelligence**, or the connected org **Org**,
  **Sandbox**, **Integration**, **Dev Org**, or similar—treat those as the
  same target unless they ask for a different credential.
- You can access selected metadata. You **cannot** compare orgs or run mass
  analysis / full-org scans—that hits limits and takes too long. If a list is
  truncated or incomplete, say you cannot finish that breadth of scan and ask
  the user to narrow the request.

## Pattern And Type Rules

- **Always quote CLI wildcards** (`--pattern 'Account*'`). Unquoted `*` is
  expanded by the shell. MCP `pattern` does not need shell quotes.
- **`search`** only covers `ApexPage`, `ApexClass`, `ApexTrigger`, and
  `ApexComponent`. Pattern ≥ 2 characters, at most one `*`.
- **`list` for CustomField / FieldSet / DuplicateRule / ListView** — pattern
  must start with the SObject name and a dot (e.g. `Account.Name`,
  `Account.namespace__Name__c`). You cannot list every item of every object.
- **`list` for Flow** — `--pattern` matches API name, Flow label, and
  triggering object API name.
- **Profiles** — reading Profile details is not supported. Tell the user you
  cannot answer questions about Profile contents. Listing Profile names may
  still be attempted if useful, but do not claim you can read their body.
- **Reports, Dashboards, and Folders** — listing is not supported; say so.

## Apex Tests

- You cannot run all tests or local tests.
- Ask the user which test class names to run, then pass them via
  `--apex-unit-tests` / `apexUnitTests` (comma-separated).

## How To Call

```sh
agentia cicd metadata explore --action describe_type --object-type ApexClass --json
agentia cicd metadata explore --action list --object-type ApexClass --pattern 'Account*' --json
agentia cicd metadata explore --action search --pattern 'Cont*' --json
agentia cicd metadata explore --action read --object-type ApexClass --full-name MyClass --json
agentia cicd metadata explore --action find_references --object-type ApexClass --full-name MyClass --json
agentia cicd metadata explore --action run_apex_tests --apex-unit-tests MyClassTest --json
```

| Surface | Name |
| --- | --- |
| CLI | `agentia cicd metadata explore` |
| MCP | `agentia_metadata_explore` |

Tool/CLI output is YAML inside `output` (human mode prints YAML; `--json` /
MCP return `{ output, credentialId? }`). **When talking to the user, respond in
XML—not YAML.** Summarize findings; do not dump full tool YAML unless asked.
Never echo session Ids, API keys, or other secrets.

## Gathering Context For Generated Code

When helping the user design or draft Salesforce metadata (local edits only):

- Prefer **local files**, then Org Intelligence `list` / `search` / `read` /
  `describe_type` / `find_references` for accurate names and patterns.
- When drafting new Apex tests, search local code or ask about existing
  conventions (data factories, test setup) before querying the org.
- Present draft code with the client's normal artifact / code-block features.
  Org Intelligence does not write metadata to the org.

## Safety

- Stay on the supported read actions above—no metadata edits, no org data.
- Prefer sandbox/dev credentials; treat production as explicit and high-risk.
- Narrow `--pattern` when lists are large or truncated.
- Experimental command: expect a warning in human/JSON output.

## Reference

Flags, MCP args, examples, and gotchas:
[references/metadata-explore.md](references/metadata-explore.md)

Copado dependency graph (`--path`, context defaults, human table):
[references/metadata-dependency.md](references/metadata-dependency.md)

## Report Back

Report actions run, object type / fullName / pattern, credential Id (never
session Id), and outcome (names found, test result summary, or error). Do not
include secrets. Use XML in the user-facing reply.
