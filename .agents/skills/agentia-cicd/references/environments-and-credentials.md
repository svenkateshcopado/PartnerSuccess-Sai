<!-- Agentia managed skill file: agentia setup skills -->

# CICD Environments And Credentials Reference

Use this reference for `agentia cicd environment ...`, `agentia cicd environment auth ...`, and `agentia cicd credential ...`.

`auth set --cicd` stores the API key used by the CLI. `cicd credential` lists, creates, updates, opens, or authenticates Copado environment credential records. They are different credential types.

## Named CICD Connections

Use a named connection when story lifecycle should stay on the default/production Copado org while function, template, or extension work targets a sandbox.

```sh
agentia auth set --cicd "$SANDBOX_KEY" --custom-url https://test.api.copado.com --connection sandbox --kind sandbox
agentia cicd function upsert MyFn --file ./fn.json --cicd-connection sandbox
agentia auth get --cicd --json
agentia auth unset --connection sandbox --yes
```

- `--cicd-connection <name>` is available only on `agentia cicd ...` commands (and MCP `cicdConnection` on CICD tools). It does not appear on `ai`, `adv`, `testing`, or `auth`.
- `AGENTIA_CICD_CONNECTION=<name>` sets a session default for `cicd` commands without changing keychain storage.
- Do not combine a named connection with `AGENTIA_CICD_API_KEY` / `AGENTIA_CICD_BASE_URL`; the CLI errors instead of silently picking one.
- Connections tagged `--kind production` require confirmation (CLI TTY), `--yes`, or `AGENTIA_CICD_ALLOW_PRODUCTION=true` (required for MCP).

## Environment Commands

| Command | Use For | Notes |
| --- | --- | --- |
| `environment list` | Find environments | Filter by `--name`, `--org-id`, `--platform`, `--type`, cursor, and page size. |
| `environment get ID` | Inspect one environment | Read before updates, credential changes, or auth checks. |
| `environment create NAME` | Create an environment | Set `--type`; platform defaults to SFDX. |
| `environment update ID` | Sparse environment changes | Use only the fields the user wants changed. |
| `environment open [ID]` | Open an environment | Uses the project default environment when ID is omitted. CLI-only navigation helper. |
| `environment auth status ID` | Validate auth for an environment credential | Auto-selects when possible; use `--credentialid` to disambiguate. |
| `environment auth web login ID` | Complete browser OAuth for an environment credential | CLI-only interactive browser flow. Supports bounded port and timeout flags. |

Examples:

```sh
agentia cicd environment list --type Sandbox --json
agentia cicd environment get <environment-id> --json
agentia cicd environment auth status <environment-id> --credentialid <credential-id> --json
```

## Credential Commands

| Command | Use For | Notes |
| --- | --- | --- |
| `credential list` | Find credentials across environments | Optional `--name`, `--page-size`, and `--cursor`. OAuth signatures are never returned. |
| `credential create` | Create a Copado environment credential | Requires `--environmentid` and `--name`; `--default` marks it default. |
| `credential update ID` | Update a Copado credential by ID | No environment flag; resolves environment/orgType from the credential. |
| `credential open ID` | Open a credential in the browser | CLI-only navigation helper. |
| `credential auth status ID` | Validate a specific credential | Derives the environment from GET `/corpus/credentials/{id}`. |
| `credential auth web login ID` | Browser OAuth for a specific credential | CLI-only; derives the environment from the credential. |

Examples:

```sh
agentia cicd credential list --name CI --json
agentia cicd credential create --environmentid <environment-id> --name "CI User" --default --json
agentia cicd credential update <credential-id> --no-default --json
agentia cicd credential open <credential-id>
agentia cicd credential auth status <credential-id> --json
agentia cicd credential auth web login <credential-id>
```

## When To Use Which Credential

- Use `agentia auth set --cicd` when the CLI cannot authenticate to the Copado CICD API.
- Use `agentia cicd credential list` to discover credentials without first knowing an environment ID.
- Use `agentia cicd credential create/update` when a Copado environment needs a Salesforce org credential record.
- Use `agentia cicd credential auth web login` when you already know the credential ID; use `agentia cicd environment auth web login` when you want automatic/default selection within an environment.
- Use `agentia auth get --cicd --json` to inspect local CLI auth status without exposing the raw API key.

## Gotchas

- Custom Domain environments are not supported by the credential create/update helpers.
- Create still reads the environment first and copies its org type into the credential payload; update and credential-targeted auth derive environment/orgType from the global credential record.
- Environment authentication can auto-select only when there is a single obvious credential. Pass `--credentialid` if multiple credentials exist.
- Browser login and open are intentionally CLI-only; MCP exposes `agentia_credential_auth_status` for non-interactive validation.
