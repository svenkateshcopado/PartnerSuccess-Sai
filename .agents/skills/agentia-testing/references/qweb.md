<!-- Agentia managed skill file: agentia setup skills -->

# QWeb Keyword Reference for CRT

QWeb is the web-automation Robot Framework library used by Copado Robotic Testing in `.robot` suites (`agentia testing job run`) and browser sessions (`agentia testing browser start <job-id> --project <project-id>`).

For goal-driven exploration in a browser session, pair this reference with [flow-automation.md](flow-automation.md). For Salesforce Lightning, also load [qforce.md](qforce.md).

## Syntax & Formatting Rules

- **4+ space separator**: Separate the keyword name, positional arguments, and `key=value` named arguments with **at least 4 spaces** (`KeywordName    arg1    arg2    anchor=Header`). Never use a single space—Robot Framework treats `ClickText Login` as a single nonexistent keyword name.
- **Prefer visible text over XPath**: `PartialMatch` is `True` by default in browser sessions (`SetConfig    PartialMatch    False` forces exact matches).
- **`anchor=<text>` for disambiguation**: When the same text appears multiple times, pass `anchor=<nearby text>` (`ClickText    Edit    anchor=Profile`). Use 1-based `index=<N>` only as a last resort.
- **Booleans**: Capitalize `True` and `False` (`clear=False`, `partial_match=False`).
- **Submitting on Enter**: Append `\n` to `TypeText` (`TypeText    Search    laptop\n`) or run `PressKey    ${EMPTY}    {ENTER}`.
- **XPath `=` escaping**: In browser testing (`testing browser execute`), Agentia automatically escapes `=` inside `//...` XPath tokens so Robot Framework does not misread `@id="x"` as a named parameter.

## Keyword Catalog

### Navigation

| Keyword | Form | Notes |
| --- | --- | --- |
| `GoTo` | `GoTo    https://example.com` | Navigate to a full URL (`https://...`). |
| `Back` / `Forward` | `Back` | Browser history navigation. |
| `RefreshPage` | `RefreshPage` | Reload the current page. |
| `Open Browser` | `Open Browser    about:blank    chrome` | Suite setup; already executed during `testing browser start` unless `--no-browser` is passed. |
| `Close All Browsers` | `Close All Browsers` | Suite teardown. Do not call during an active browser session; use `testing browser stop` instead. |

### Clicking

| Keyword | Form | When to Use |
| --- | --- | --- |
| `ClickText` | `ClickText    <text>    [anchor=<text>]` | Default choice for any button, link, or tab with visible text. |
| `ClickItem` | `ClickItem    <alt_or_title>    [anchor=<text>]` | Click by `alt`, `title`, `tooltip`, `data-tooltip`, or `data-icon` (ideal for icon-only buttons). |
| `ClickElement` | `ClickElement    <xpath>` | Last resort when neither `ClickText` nor `ClickItem` can target the element. |
| `ClickCheckbox` | `ClickCheckbox    <label>    on\|off` | Idempotently set a checkbox to `on` or `off`. |
| `ClickList` | `ClickList    <list_locator>    <item_text>` | Click an item inside a list widget. |
| `ClickCell` | `ClickCell    <row>    <col>` | Click a cell inside the active table (requires `UseTable` first). |

### Typing & Form Inputs

| Keyword | Form | Notes |
| --- | --- | --- |
| `TypeText` | `TypeText    <label>    <value>    [clear=False]` | Clears the field and types `<value>`. Append `\n` to submit. |
| `TypeSecret` | `TypeSecret    <label>    <value>` | Same as `TypeText`, but masks the value in logs and Agentia browser history. |
| `DropDown` | `DropDown    <label>    <option>` | Select an option from a native HTML `<select>` element. |
| `GetInputValue` | `GetInputValue    <label>` | Read the current value of an input field. |

### Verification & Reading

| Keyword | Form | Notes |
| --- | --- | --- |
| `VerifyText` | `VerifyText    <text>    [timeout=30]` | Assert visible text appears on the page (preferred over `Sleep` for waiting). |
| `VerifyNoText` | `VerifyNoText    <text>    [timeout=10]` | Assert text does not appear (or disappears). |
| `VerifyItem` | `VerifyItem    <alt_or_title>` | Assert an element with the given `alt`/`title`/`tooltip` exists. |
| `VerifyElement` | `VerifyElement    <xpath>    [timeout=30]` | Assert an XPath exists in the DOM. |
| `VerifyValue` | `VerifyValue    <label>    <expected>` | Assert an input field holds `<expected>`. |
| `VerifyCheckboxValue` | `VerifyCheckboxValue    <label>    on\|off` | Assert a checkbox state. |
| `GetText` | `GetText    <locator>` | Read visible text of an element. |
| `GetAttribute` | `GetAttribute    <locator>    <attribute>` | Read an attribute (e.g., `href`, `aria-expanded`, `outerHTML`). |
| `GetTitle` | `GetTitle` | Read the document title (also useful as a harmless keepalive keyword in browser sessions). |

### Hover, Scroll, Drag & Keyboard

| Keyword | Form | Notes |
| --- | --- | --- |
| `HoverText` / `HoverElement` | `HoverText    <text>` | Hover over an element to reveal menus or tooltips. |
| `Scroll` | `Scroll    <locator>    page_down\|page_up\|<px>` | Scroll an element or `//html` for the full page. |
| `ScrollTo` | `ScrollTo    <text_locator>` | Scroll until `<text_locator>` is in view. |
| `DragDrop` | `DragDrop    <source>    <target>` | Drag one element onto another. |
| `PressKey` | `PressKey    <locator>    <key>` | Use `${EMPTY}` for global key press (`{ENTER}`, `{ESC}`, `{TAB}`). |

### Stateful Tables

Call `UseTable` once to bind the active table, then address cells by 1-based row/column (`r1`, `c2`) or header/row text:

```robotframework
UseTable       Users
ClickCell      r1    Email
VerifyTable    r1    Status    Active
```

### Configuration (`SetConfig`)

| Setting | Example | Purpose |
| --- | --- | --- |
| `DefaultTimeout` | `SetConfig    DefaultTimeout    20s` | Global auto-wait timeout for locators (default `10s`). |
| `XHRTimeout` | `SetConfig    XHRTimeout    30s` | Wait for pending XHR/network activity before acting. |
| `PartialMatch` | `SetConfig    PartialMatch    False` | Require exact text matches instead of substring matches. |
| `CaseInsensitive` | `SetConfig    CaseInsensitive    True` | Enable case-insensitive text matching. |
| `ClickToFocus` | `SetConfig    ClickToFocus    True` | Click inputs before typing (enabled by default in browser sessions). |

## Decision Tree

1. **Open a URL** -> `GoTo    https://...`
2. **Click readable text** -> `ClickText    <text>` (add `anchor=<nearby>` if repeated)
3. **Click an icon/image with no text** -> `ClickItem    <alt_or_title>`, else `ClickElement    <xpath>`
4. **Type into a field** -> `TypeText    <label>    <value>` (or `TypeSecret` for passwords/tokens)
5. **Select from a native `<select>`** -> `DropDown    <label>    <option>`
6. **Toggle a checkbox** -> `ClickCheckbox    <label>    on`
7. **Wait for page readiness** -> `VerifyText    <landmark>    timeout=30` (avoid `Sleep`)
8. **Work with a table** -> `UseTable    <table_name>` -> `VerifyTable` / `ClickCell`
