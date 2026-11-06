<!-- Agentia managed skill file: agentia setup skills -->

# CICD Pipelines Reference

Use this reference for `agentia cicd pipeline ...`, `agentia cicd pipeline automation ...`, `agentia cicd pipeline quality-gate ...`, `agentia cicd pipeline connection ...`, `agentia cicd pipeline stage-connection ...`, `agentia cicd stage ...`, and `agentia cicd extension-configuration ...`.

Pipeline connections, stage connections, stages, automation rules, quality gates, and extension configurations are related but distinct. Read the target object before mutating it. These pipeline quality gates are not local `cicd work test` quality gates.

## Pipeline Commands

| Command | Use For | Notes |
| --- | --- | --- |
| `pipeline list` | Find pipelines | Filter by `--active`, `--name`, `--platform`, cursor, and page size. |
| `pipeline get ID` | Inspect one pipeline | Returns describe-style details, including embedded connections. JSON may also include redesigned `automations` / `qualityGates` rule aggregates (one quality-gate entry per condition row). |
| `pipeline create NAME` | Create a pipeline | Common flags: `--platform`, `--main-branch`, `--git-repository-id`. |
| `pipeline update ID` | Sparse pipeline changes | Set `--name`, branch, repository, or conflict strategy fields. |
| `pipeline open ID` | Open in browser | CLI-only navigation helper. |

Example:

```sh
agentia cicd pipeline list --platform SFDX --active --json
agentia cicd pipeline get <pipeline-id> --json
```

## Automation Rules

| Command | Use For | Notes |
| --- | --- | --- |
| `pipeline automation list --pipeline-id <id>` | List automation rules | Filters: `--active`, `--name`, `--source-action`, `--execution-time`, `--include-system-generated`. |
| `pipeline automation get ID --pipeline-id <id>` | Inspect one rule | Accepts Id or name. |
| `pipeline automation create --pipeline-id <id> ...` | Create an inactive rule | Scopes: `promotion`, `backPromotion`, `environmentSyncBackPromotion`, `advanced`. Requires stage/environment targets; Scheduled needs `--cron-expression`. Optional `--filter-criteria` is a user-story filter: builder `{mode,logic,conditions[]}` or custom `{mode:"custom",whereCondition}`. |
| `pipeline automation update ID --pipeline-id <id> ...` | Sparse update | Scope is immutable after create. |
| `pipeline automation activate\|deactivate ID --pipeline-id <id>` | Lifecycle | Salesforce Id only (not name). Requires Copado Deployer ≥ 27.46. |
| `pipeline automation delete ID --pipeline-id <id> --yes` | Delete | Confirmation required for headless/JSON. |
| `pipeline automation open ID` | Open in browser | Salesforce Id only. |

## Quality Gates

| Command | Use For | Notes |
| --- | --- | --- |
| `pipeline quality-gate list --pipeline-id <id>` | List quality gates | Filters: `--name`, `--tool`. |
| `pipeline quality-gate get ID --pipeline-id <id>` | Inspect one gate | Aggregate may include multiple conditions. |
| `pipeline quality-gate create --pipeline-id <id> ...` | Create inactive gates | Requires an active `--extension-configuration-id` and targeting (`--entire-pipeline` or stage/environment Ids). Optional `--filter-criteria` is a metadata-change filter (`Name`/`Type`/`Directory` conditions + numbered `logic`). Create may return an array. |
| `pipeline quality-gate update ID --pipeline-id <id> ...` | Sparse update | Gate must be inactive; update uses singular `--stage-id` / `--environment-id`. |
| `pipeline quality-gate activate\|deactivate ID --pipeline-id <id>` | Lifecycle | Salesforce Id only. |
| `pipeline quality-gate delete ID --pipeline-id <id> --yes` | Delete inactive gate | Confirmation required for headless/JSON. |
| `pipeline quality-gate open ID` | Open in browser | Salesforce Id only. |

## Extension Configurations

| Command | Use For | Notes |
| --- | --- | --- |
| `extension-configuration list` | Discover configs | Filters: `--name`, `--tool`, `--test-type`, `--active`. |
| `extension-configuration get ID` | Inspect one config | Accepts Id or name. |
| `extension-configuration open ID` | Open in browser | Salesforce Id only. Create/update/activate are not exposed (gateway lifecycle currently unavailable). |

## Environment Connections

Pipeline connections define source-to-destination environment promotion edges.

| Command | Use For |
| --- | --- |
| `pipeline connection list --pipeline-id <id>` | List environment edges in a pipeline. |
| `pipeline connection create --pipeline-id <id> ...` | Create one edge or pass a JSON file for bulk creation. |
| `pipeline connection update --pipeline-id <id> ...` | Update one edge or pass a JSON file for bulk update. |
| `pipeline connection delete --pipeline-id <id> ... --yes` | Delete one or more edges. |
| `pipeline connection open ID` | Open one connection in the browser. |

Single-create example:

```sh
agentia cicd pipeline connection create --pipeline-id <pipeline-id> --source-environment-id <dev-id> --destination-environment-id <uat-id> --branch main --json
```

## Stages And Stage Connections

Stages are reusable stage records. Stage connections order those stages inside a pipeline.

| Command | Use For |
| --- | --- |
| `stage list|get|create|update|delete|open` | Manage stage records. |
| `pipeline stage-connection list --pipeline-id <id>` | Read ordered stages for a pipeline. |
| `pipeline stage-connection create --pipeline-id <id> --stage-id <id>` | Add a stage to a pipeline chain. |
| `pipeline stage-connection update ID --pipeline-id <id>` | Rewire the next stage connection. |
| `pipeline stage-connection delete ID --pipeline-id <id> --yes` | Remove a stage connection. |
| `pipeline stage-connection open ID` | Open the stage connection in a browser. |

## Gotchas

- `pipeline connection` is an environment promotion edge.
- `pipeline stage-connection` is the ordered stage chain inside a pipeline.
- `cicd stage` manages stage records that can be referenced by stage connections.
- Pipeline `quality-gate` commands manage Copado pipeline quality gates. Local script gates remain under `cicd work test`.
- Activate/deactivate and open require Salesforce Ids, not names.
- Delete commands prompt in interactive mode. Use `--yes` only when the user already confirmed the destructive action.
- Repository setup is a neighboring domain: pipelines can reference `--git-repository-id`, but repository lifecycle commands are under `agentia cicd repository`.
