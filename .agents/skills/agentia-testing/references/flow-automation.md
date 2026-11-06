<!-- Agentia managed skill file: agentia setup skills -->

# Goal-Driven Flow Automation in CRT Browser Testing

Use this methodology when turning a natural-language goal ("create a lead", "add a product to the cart and verify checkout") into a verified sequence of Robot Framework keywords against an active `agentia testing browser` session.

Applies to `QWeb` (default), `--library QForce` (see [qforce.md](qforce.md) for Lightning-specific rules layered on top), and `--library QMobile`.

## The Core Loop

```text
Observe -> Act (one logical step) -> Verify expected state -> Recover if needed -> Continue
```

Do **not** write an entire multi-page `.robot` script up front and fire it in one `testing browser execute --file` call. Every page transition is a hypothesis until confirmed against the browser session. Execute one logical step at a time, verify the transition, and then choose the next keyword. Batching is only appropriate for coupled inputs on the same verified view (such as `TypeText    Username    ...` + `TypeSecret    Password    ...`).

```sh
# 1. Act
agentia testing browser execute --project <project-id> --line "GoTo    https://example.com" --json

# 2. Verify
agentia testing browser execute --project <project-id> --line "VerifyText    Example Domain" --json

# 3. Observe interactive elements before the next decision
agentia testing browser inspect --project <project-id> --json
```

## Choosing Locators (Priority Order)

Always prefer semantic locators over structural XPaths:

1. **Visible text** (`ClickText`, `TypeText`, `TypeSecret`, `VerifyText`, `DropDown`, `ClickCheckbox`). Disambiguate repeated text with `anchor=<nearby text>` before reaching for `index=<N>`.
2. **Unique attribute** (`alt`, `title`, `tooltip`, `data-icon`) when there is no visible text — use `ClickItem` / `VerifyItem`.
3. **XPath as a last resort** (`ClickElement`, `VerifyElement`) only when text and attribute locators cannot reach the element.

While exploring unfamiliar pages, pass a short bounded timeout (`timeout=3`) so a wrong locator fails in 3 seconds instead of 10 seconds:

```sh
agentia testing browser execute --project <project-id> --line "ClickText    Sign In    timeout=3" --json
```

Drop the tight `timeout=3` override when curating the final exported `.robot` suite.

## Why "Completed" Execution Still Needs Verification

`testing browser execute` returning `status: "completed"` only proves the keyword ran without throwing an error—it does **not** prove that navigation succeeded, a form submitted, or a modal opened.

After any state-changing keyword (`GoTo`, `Click*`, `Type*`, `DropDown`, `PickList`, `ComboBox`, `PressKey`), run a `Verify*` keyword targeting content **unique to the new state**:
- After login -> verify dashboard heading or app navigation.
- After opening a modal -> verify a field label inside the modal before typing.
- After saving a record -> verify the saved state or record detail field.

Watch for missing workflow transitions:
- **Typed into a search box**: Append `\n` to the `TypeText` value to submit on Enter, or click the search button.
- **Filled form fields**: Click `Save` / `Submit` before asserting the outcome.

## Observing Page State: `inspect` + `screenshot` Overlay

| Question | Command |
| --- | --- |
| Which interactive elements are visible? | `agentia testing browser inspect --project <project-id> --json` |
| What does the viewport look like with detection boxes? | `agentia testing browser screenshot --project <project-id> --output /tmp/page.png --json` |
| What is the raw HTML (`outerHTML`)? | `agentia testing browser inspect --project <project-id> --dom --json` |

### Reading `inspect` and `screenshot` Together
The PNG saved by `testing browser screenshot` is not a plain screenshot: the CRT inspection engine draws colored bounding rectangles (teal by default from `SetConfig    HighlightColor    teal`) around every detected UI element. Each rectangle corresponds to an entry in the `systemState` array from `testing browser inspect`:
- `annotationIndex` — matches the numbered/boxed element in the detection pass.
- `readableTexts` (`ownText`, `ariaLabel`, `nearbyTexts`) — exact strings to pass to `ClickText` / `TypeText` and `anchor=`.
- `elementType` and `role` — distinguishes inputs, buttons, links, and `role="combobox"` lookups.
- `isVisible`, `isInteractive`, `isEnabled`, `isCovered` — if `isCovered: true`, a modal, toast, or sticky header is covering the element and must be closed or scrolled past first.

## Recovery Protocol

When an action or verification fails:
1. **Stop immediately.** Do not execute the next planned step.
2. **Inspect first** (`testing browser inspect` and `testing browser screenshot`) — never retry blindly.
3. **Compare expected vs. actual state**:
   - *Still on the previous view?* A workflow transition (submit, save, menu click) didn't fire. Complete the transition rather than swapping locators.
   - *On the expected view?* The locator was wrong. Pick up to 3 semantic alternatives directly from `systemState[].readableTexts` (`anchor=`, `ClickItem`, etc.).
4. **Wrong-but-successful action** (e.g., clicked the wrong `New` button):
   - Inspect where you landed, restore the prior view (`Back` or re-navigate), verify restoration, and retry with `anchor=<nearby text>` or `SetConfig    PartialMatch    False`.
   - Remember that successful wrong clicks land in `testing browser history` (`status: "completed"`) — strip them when curating the final `.robot` file.

## Tuning the Session for Agent-Driven Flows

- **Exact text matching**: Bootstrap sets `PartialMatch    True`. On text-dense pages (especially Salesforce Lightning), switch to exact matching since you have exact `readableTexts` from `inspect`:
  ```sh
  agentia testing browser execute --project <project-id> --line "SetConfig    PartialMatch    False" --json
  ```
- **XHR-heavy pages**: Raise timeouts with `SetConfig    DefaultTimeout    20s` and `SetConfig    XHRTimeout    30s` instead of adding `Sleep`.

## Exporting and Promoting the Proven Flow

Failed probes (`status: "failed"`) are automatically excluded by `testing browser history`:

```sh
agentia testing browser history <job-id> --project <project-id> --lines-only > flow.robot
```

Curate `flow.robot` by removing exploratory detours, temporary `timeout=3` overrides, and duplicate steps, then wrap it in a standard Robot Framework suite for `agentia testing job files upload` and `agentia testing job run`:

```robotframework
*** Settings ***
Library           QWeb
Suite Setup       Open Browser    about:blank    chrome
Suite Teardown    Close All Browsers

*** Test Cases ***
Verified Flow
    GoTo          https://example.com
    VerifyText    Example Domain
```
