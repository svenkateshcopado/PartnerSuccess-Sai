<!-- Agentia managed skill file: agentia setup skills -->

# QForce & Salesforce Lightning Reference for CRT

QForce is Copado Robotic Testing's Salesforce keyword library. It is a superset of [QWeb](qweb.md): all QWeb keywords (`ClickText`, `TypeText`, `VerifyText`, `UseTable`, etc.) work unchanged, and QForce adds Salesforce Lightning-aware locators and keywords on top.

To start a Salesforce browser session:

```sh
agentia testing browser start <job-id> --project <project-id> --library QForce --json
agentia testing browser execute --project <project-id> --line "SetConfig    PartialMatch    False" --json
```

When these Salesforce-specific rules conflict with generic QWeb text-first guidance, **the Salesforce rule wins**.

## Mandatory Salesforce Rules

1. **Always normalize app state with `LaunchApp`**:
   Immediately after login—and before any app-specific click, tab navigation, or assertion—run:
   ```robotframework
   LaunchApp    Sales
   ```
   `LaunchApp` is idempotent: it checks the active Lightning app and only opens the App Launcher when needed. Never skip it just because the right app appears open, and do not replace it with manual clicks on the App Launcher waffle icon.
2. **Verify Record Details with `VerifyField`, never `VerifyText`**:
   Lightning record pages contain repeated labels in headers, related lists, and activity timelines, causing `VerifyText` to pass for the wrong reason.
3. **Three dropdown families require three distinct keywords**:
   - Native HTML `<select>` -> `DropDown    <label>    <value>`
   - Lightning custom picklist (button/div/listbox widget) -> `PickList    <label>    <value>`
   - Lookup / searchable combobox (`input` with `role="combobox"`) -> `ComboBox    <locator>    <value>    timeout=10`
4. **Lookups (`ComboBox`) only select existing records**:
   Never finish a lookup field with `TypeText` (typed text is not a selected record). If the target record does not exist, use the nested `New <Object>` creation flow.
5. **Never hard-code org-specific Lightning URLs or record IDs**:
   Navigate via `LaunchApp` and object tabs so tests survive sandbox refreshes. Store credentials in CRT Variables (`testing variable`) or User Parameters (`testing user-parameter`) and type secrets with `TypeSecret`.

## QForce Keyword Catalog

In `.robot` files and `testing browser execute`, always use `KeywordCase` (`LaunchApp`, `VerifyField`, `PickList`, `ComboBox`). Separate arguments with 4+ spaces.

| Keyword | Form | When to Use |
| --- | --- | --- |
| `LaunchApp` | `LaunchApp    <Exact App Name>` | Open a Salesforce Lightning app via the App Launcher by exact name (`Sales`, `Service`). |
| `VerifyField` | `VerifyField    <label>    <expected>` | Assert a plain-text field value on a Record Details page (`VerifyField    Phone    123456789`). |
| `VerifyField` (link) | `VerifyField    <label>    <expected>    tag=a` | Assert a linked field value (lookup, owner, related record: `VerifyField    Account Name    Acme    tag=a`). |
| `VerifyField` (indexed) | `VerifyField    <label>    <expected>    <index>    [tag=a]` | Disambiguate when the same field label appears multiple times on the Details page. Discover `<index>` with `GetFieldValue` first. |
| `GetFieldValue` | `GetFieldValue    <label>    [index]` | Read the value of the Nth field with `<label>` to discover which index to pass to `VerifyField`. |
| `PickList` | `PickList    <label>    <value>    [index=1]    [timeout=0]` | Select an option from a Lightning custom picklist (`PickList    Stage    Closed Won`). |
| `ComboBox` | `ComboBox    <locator>    <value>    timeout=10` | Search and select an **existing** record in a Lightning lookup/combobox (`ComboBox    Account Name    Acme    timeout=10` or `ComboBox    Search Accounts...    Acme    timeout=10`). |

## Record Details Verification Ladder

On a Salesforce record's **Details** tab, follow this order:

1. **Plain field**: `VerifyField    <label>    <expected>`
2. **Linked field (lookup/owner)**: `VerifyField    <label>    <expected>    tag=a`
3. **Duplicate field label on page**: Probe indexes with `GetFieldValue`, then assert with indexed `VerifyField`:
   ```robotframework
   GetFieldValue    Account Name    1
   GetFieldValue    Account Name    2
   VerifyField      Account Name    Acme Corp    2    tag=a
   ```
4. **Never use `VerifyText` as the primary Details assertion**, and do not assert on ephemeral toast messages (toasts vanish quickly; verify the saved record's Details instead).

## Lookup Fields & Nested Record Creation

When filling a lookup field (such as `Account Name` on a Contact or Opportunity):

- **If the target record exists**:
  ```robotframework
  ComboBox       Account Name    Acme Corp    timeout=10
  ClickText      Save
  ClickText      Details
  VerifyField    Account Name    Acme Corp    tag=a
  ```
- **If `ComboBox` fails (`Could not find combobox ... with value ...`) or the record does not exist**:
  Do not retry `ComboBox` in a loop and do not leave raw `TypeText` in the input. Trigger the nested `New <Object>` modal from the lookup instead:
  ```robotframework
  ClickText      Account Name
  ClickText      New Account
  TypeText       Account Name    Acme Corp
  ClickText      Save
  ```

## Recognising Dropdown Types via `testing browser inspect`

When unsure whether a field uses `DropDown`, `PickList`, or `ComboBox`, run `agentia testing browser inspect --project <project-id> --json` and check the element in `systemState`:
- `elementType: "select"` -> `DropDown`
- Clickable button/div showing the current picklist value (not an `input`) -> `PickList`
- `elementType: "input"` with `role: "combobox"` or placeholder `Search ...` -> `ComboBox`
