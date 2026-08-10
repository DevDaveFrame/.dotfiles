---
name: bubbletea
description: Use this skill when the user asks to build a terminal UI (TUI), CLI with interactive elements, or anything using the BubbleTea framework in Go, or when user wants to add interactive terminal components (tables, lists, forms, spinners, text inputs)
---

## Before Writing Code

**Determine the version.** Check existing `go.mod` for import paths:
- `github.com/charmbracelet/bubbletea` → **v1**
- `charm.land/bubbletea/v2` → **v2**

For new projects, **default to v2** unless the user requests v1. If upgrading from v1, see the [upgrade-v2](upgrade-v2/SKILL.md) sub-skill.

**Ask whether to scaffold or add to an existing project.** If scaffolding:
- Generate `go.mod`, `main.go`, model files, and a `Makefile` with `run`, `build`, and `lint` targets
- Use `go run .` as the default run command

If adding to an existing project, read the existing code first to match conventions.

## Library Stack

Use the full Charm ecosystem as needed:
- **bubbletea** — core framework (event loop, model/update/view)
- **lipgloss** — styling (colors, borders, padding, layout)
- **bubbles** — pre-built components (textinput, viewport, list, table, spinner, paginator, help, key)
- **huh** — structured forms and prompts
- **log** — structured logging (`charmbracelet/log`)

Import paths:
- **v1:** `github.com/charmbracelet/bubbletea`, `github.com/charmbracelet/lipgloss`, `github.com/charmbracelet/bubbles/...`
- **v2:** `charm.land/bubbletea/v2`, `charm.land/lipgloss/v2`, `charm.land/bubbles/v2/...`

## Architecture

### Receiver Style
Use whichever receiver type fits the situation:
- **Value receivers** for small, simple models (follows Elm-style purity)
- **Pointer receivers** for larger models or when helper methods need to mutate state

Never modify model state outside of `Update()`. No goroutine should touch model fields directly.

### Model Structure — Scale Appropriately
- **Small apps**: Single model with a state/view enum is fine. Don't over-architect.
- **Medium apps**: Extract child models for distinct screens or complex components. Root model routes messages and composes layout.
- **Large apps**: Full hierarchical model tree. Root model is a router/compositor. Child models own their domain. Messages flow down; updated models and commands flow back up.

Start flat. Extract when complexity demands it.

### Core Pattern — Model/Update/View

**v1:**
```go
type model struct {
    width  int
    height int
}

func (m model) Init() tea.Cmd {
    return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        switch msg.String() {
        case "q", "ctrl+c":
            return m, tea.Quit
        }
    case tea.WindowSizeMsg:
        m.width = msg.Width
        m.height = msg.Height
    }
    return m, nil
}

func (m model) View() string {
    return "Hello, BubbleTea!"
}
```

**v2** — two key differences: `View()` returns `tea.View`, and key messages use `tea.KeyPressMsg`:
```go
type model struct {
    width  int
    height int
}

func (m model) Init() tea.Cmd {
    return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyPressMsg:
        switch msg.String() {
        case "q", "ctrl+c":
            return m, tea.Quit
        }
    case tea.WindowSizeMsg:
        m.width = msg.Width
        m.height = msg.Height
    }
    return m, nil
}

func (m model) View() tea.View {
    return tea.NewView("Hello, BubbleTea!")
}
```

### main.go Pattern

**v1** — terminal features set via program options:
```go
func main() {
    p := tea.NewProgram(initialModel(), tea.WithAltScreen())
    if _, err := p.Run(); err != nil {
        fmt.Fprintf(os.Stderr, "error: %v\n", err)
        os.Exit(1)
    }
}
```

**v2** — terminal features set declaratively in `View()`, so `NewProgram` is simpler:
```go
func main() {
    p := tea.NewProgram(initialModel())
    if _, err := p.Run(); err != nil {
        fmt.Fprintf(os.Stderr, "error: %v\n", err)
        os.Exit(1)
    }
}

// In the model's View:
func (m model) View() tea.View {
    v := tea.NewView(m.renderContent())
    v.AltScreen = true
    v.MouseMode = tea.MouseModeCellMotion
    return v
}
```

## v2 Declarative View System

In v2, `View()` returns a `tea.View` struct. Terminal features that were previously set via `tea.NewProgram()` options or imperative commands now live as fields on the View:

| View Field | Type | Purpose |
|------------|------|---------|
| `AltScreen` | `bool` | Enter/exit alternate screen |
| `MouseMode` | `tea.MouseMode` | Mouse input (`MouseModeCellMotion`, `MouseModeAllMotion`, `MouseModeNone`) |
| `ReportFocus` | `bool` | Receive focus/blur events |
| `DisableBracketedPasteMode` | `bool` | Disable paste detection |
| `WindowTitle` | `string` | Set terminal title |
| `Cursor` | `*tea.Cursor` | Control cursor position, shape, and color |
| `ForegroundColor` | `color.Color` | Set terminal foreground color |
| `BackgroundColor` | `color.Color` | Set terminal background color |
| `ProgressBar` | `float64` | Native terminal progress indicator |
| `KeyboardEnhancements` | `tea.KeyboardEnhancement` | Enhanced key input (shift+enter, key release, etc.) |

This means features can change dynamically per render — toggle alt screen, enable/disable mouse, move the cursor — all by changing the View fields.

### Cursor Control (v2)
```go
func (m model) View() tea.View {
    v := tea.NewView(m.content)
    v.Cursor = tea.NewCursor(m.cursorX, m.cursorY)
    v.Cursor.Shape = tea.CursorBeam       // Block, Underline, or Beam
    v.Cursor.Blink = true
    v.Cursor.Color = lipgloss.Color("205")
    return v
}
```

### Background Color Detection (v2)

Query the terminal background to adapt styles (light vs dark):
```go
func (m model) Init() tea.Cmd {
    return tea.RequestBackgroundColor
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.BackgroundColorMsg:
        m.hasDark = msg.IsDark()
        m.styles = newStyles(m.hasDark)
    }
    return m, nil
}
```

## Critical Rules

### Performance
- `Update()` and `View()` must be fast — they block the event loop.
- Offload expensive work (HTTP calls, file I/O, computation) into `tea.Cmd` functions. These run concurrently and return messages when done.
- Never do blocking I/O in `Update()` or `View()`.

### Message Ordering
- User input messages are ordered (processed from a single goroutine).
- Command result messages are **not** ordered (each runs in its own goroutine).
- If ordering matters, use `tea.Sequence()` (v2) / `tea.Sequentially()` (v1) or redesign to be order-independent.
- Use `tea.Batch()` to combine multiple commands that can run concurrently.

### Message Routing (for multi-model apps)
Three routing paths in the root model's `Update()`:
1. **Global keys** — handle directly (quit, help toggle)
2. **Active model** — route to the currently focused child
3. **Broadcast** — send `tea.WindowSizeMsg` (and similar) to ALL children

### Layout
Never hardcode dimensions. Calculate dynamically:
```go
contentHeight := m.height - lipgloss.Height(header) - lipgloss.Height(footer)
```
The Width and Height functions return the width and height of the *content* but don't account for the space occupied by the margin, padding, and border of the lipgloss Style. For that, use `GetFrameSize()` to get the sum of the margins, padding and border width for both the horizontal and vertical.
```go
verticalMarginSize, horizontalMarginSize := style.GetFrameSize()
```
This prevents overflow when components change size.

### Terminal Recovery
Panics inside `tea.Cmd` functions do NOT trigger BubbleTea's recovery. The terminal will be left in raw mode (no cursor, broken input). Recover from panics inside commands explicitly if needed.

## Key and Mouse Messages

### Key Messages

**v1** — `tea.KeyMsg` is a struct:
```go
case tea.KeyMsg:
    switch msg.String() {
    case "q":
        return m, tea.Quit
    }
    if msg.Type == tea.KeyEnter { ... }
    if msg.Alt { ... }
```

**v2** — `tea.KeyMsg` is an interface; use `tea.KeyPressMsg` (and optionally `tea.KeyReleaseMsg`):
```go
case tea.KeyPressMsg:
    switch msg.String() {
    case "q":
        return m, tea.Quit
    }
    if msg.Code == tea.KeyEnter { ... }
    if msg.Mod.Contains(tea.ModAlt) { ... }
```

v2 field mapping: `msg.Type` → `msg.Code` (rune), `msg.Runes` → `msg.Text` (string), `msg.Alt` → `msg.Mod.Contains(tea.ModAlt)`.

v2 adds: `msg.ShiftedCode`, `msg.BaseCode`, `msg.IsRepeat`, `msg.Keystroke()`.

Note: In v2, space bar returns `"space"` from `String()` (not `" "`), but `Code` is still `' '`.

### Mouse Messages

**v1** — single `tea.MouseMsg` struct:
```go
case tea.MouseMsg:
    if msg.Button == tea.MouseButtonLeft && msg.Action == tea.MouseActionPress { ... }
```

**v2** — split into specific types:
```go
case tea.MouseClickMsg:
    m := msg.Mouse()
    if msg.Button == tea.MouseLeft { ... }
case tea.MouseReleaseMsg:
case tea.MouseWheelMsg:
case tea.MouseMotionMsg:
```

v2 button renames: `MouseButtonLeft` → `MouseLeft`, `MouseButtonRight` → `MouseRight`, `MouseButtonMiddle` → `MouseMiddle`.

### Paste Messages (v2)

In v1, paste was a flag on `tea.KeyMsg` (`msg.Paste`). In v2, use dedicated types:
```go
case tea.PasteMsg:       // contains the pasted text
case tea.PasteStartMsg:  // paste began
case tea.PasteEndMsg:    // paste ended
```

## Custom Commands Pattern

```go
// Define a message type for the result
type fetchResultMsg struct {
    data string
    err  error
}

// Command function — runs concurrently, returns a message
func fetchData(url string) tea.Cmd {
    return func() tea.Msg {
        resp, err := http.Get(url)
        if err != nil {
            return fetchResultMsg{err: err}
        }
        defer resp.Body.Close()
        body, _ := io.ReadAll(resp.Body)
        return fetchResultMsg{data: string(body)}
    }
}
```

## Bubbles Components Quick Reference

| Component | v1 import | v2 import | Use For |
|-----------|-----------|-----------|---------|
| `textinput` | `bubbles/textinput` | `charm.land/bubbles/v2/textinput` | Single-line text entry |
| `textarea` | `bubbles/textarea` | `charm.land/bubbles/v2/textarea` | Multi-line text entry |
| `list` | `bubbles/list` | `charm.land/bubbles/v2/list` | Filterable, navigable lists |
| `table` | `bubbles/table` | `charm.land/bubbles/v2/table` | Tabular data with selection |
| `viewport` | `bubbles/viewport` | `charm.land/bubbles/v2/viewport` | Scrollable content area |
| `spinner` | `bubbles/spinner` | `charm.land/bubbles/v2/spinner` | Loading indicators |
| `progress` | `bubbles/progress` | `charm.land/bubbles/v2/progress` | Progress bars |
| `paginator` | `bubbles/paginator` | `charm.land/bubbles/v2/paginator` | Page navigation |
| `help` | `bubbles/help` | `charm.land/bubbles/v2/help` | Key binding help display |
| `key` | `bubbles/key` | `charm.land/bubbles/v2/key` | Key binding definitions |
| `filepicker` | `bubbles/filepicker` | `charm.land/bubbles/v2/filepicker` | File selection |

Each Bubbles component follows the same Model/Update/View pattern. Initialize in your model, call its `Update()` from yours, render its `View()` in yours.

### v2 Bubbles API Differences

**Constructors:** `NewModel()` removed — use `New()` (affects help, list, paginator, spinner, textinput).

**Width/Height:** Exported fields replaced by getter/setter methods:
```go
// v1                    // v2
m.Width = 40             m.SetWidth(40)
w := m.Width             w := m.Width()
m.Height = 24            m.SetHeight(24)
h := m.Height            h := m.Height()
```
Affects: filepicker, help, progress, table, textinput, viewport.

**DefaultKeyMap:** Package variable → function call:
```go
// v1                           // v2
km := textinput.DefaultKeyMap   km := textinput.DefaultKeyMap()
```
Affects: paginator, textarea, textinput.

**DefaultStyles():** Now takes `isDark bool`:
```go
// v1                           // v2
styles := list.DefaultStyles()  styles := list.DefaultStyles(isDark)
```
Affects: help, list, textarea, textinput.

**Textarea/Textinput styles:** Consolidated into nested struct:
```go
// v1                            // v2
model.FocusedStyle               model.Styles.Focused
model.BlurredStyle               model.Styles.Blurred
```

## Lipgloss Styling Quick Reference

Lipgloss style API is the same across versions:
```go
var style = lipgloss.NewStyle().
    Bold(true).
    Foreground(lipgloss.Color("205")).     // ANSI color
    Background(lipgloss.Color("#7D56F4")). // Hex color
    Padding(1, 2).
    Border(lipgloss.RoundedBorder()).
    BorderForeground(lipgloss.Color("63"))

// Layout helpers
lipgloss.JoinHorizontal(lipgloss.Top, left, right)
lipgloss.JoinVertical(lipgloss.Left, top, bottom)
lipgloss.Place(width, height, lipgloss.Center, lipgloss.Center, content)
```

### v2 Lipgloss Differences

**Renderer removed.** `lipgloss.NewStyle()` is a pure value — no renderer dependency. Remove any `*lipgloss.Renderer` fields.

**Output.** In v2, `Render()` produces full-fidelity ANSI; color downsampling happens at output. BubbleTea v2 handles this automatically. For standalone usage, use lipgloss writers:
```go
lipgloss.Println(style.Render("Hello"))              // stdout
lipgloss.Fprintln(os.Stderr, style.Render("Hello"))  // stderr
```

**AdaptiveColor moved.** Quick path — use compat package:
```go
import "charm.land/lipgloss/v2/compat"
color := compat.AdaptiveColor{Light: lipgloss.Color("#0000ff"), Dark: lipgloss.Color("#000099")}
```
Recommended — use `LightDark()`:
```go
hasDark := lipgloss.HasDarkBackground(os.Stdin, os.Stdout)
lightDark := lipgloss.LightDark(hasDark)
color := lightDark(lipgloss.Color("#0000ff"), lipgloss.Color("#000099"))
```

**Underline enhancements (v2).** Fine-grained underline control:
```go
s := lipgloss.NewStyle().
    UnderlineStyle(lipgloss.UnderlineCurly).
    UnderlineColor(lipgloss.Color("#FF0000"))
```

**Whitespace options changed:**
```go
// v1
lipgloss.Place(w, h, hPos, vPos, str,
    lipgloss.WithWhitespaceForeground(lipgloss.Color("#333")),
)
// v2
lipgloss.Place(w, h, hPos, vPos, str,
    lipgloss.WithWhitespaceStyle(lipgloss.NewStyle().Foreground(lipgloss.Color("#333"))),
)
```

## Debugging

When debugging, add message logging:
```go
func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    if os.Getenv("DEBUG") != "" {
        f, _ := os.OpenFile("debug.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
        fmt.Fprintf(f, "msg: %T %+v\n", msg, msg)
        f.Close()
    }
    // ... rest of Update
}
```
Run with `DEBUG=1 go run .` and `tail -f debug.log` in another terminal.

## Testing with teatest

**v1 import:** `github.com/charmbracelet/x/exp/teatest`

### Environment Setup

**v1** — disable colors in tests:
```go
func init() {
    lipgloss.SetColorProfile(termenv.Ascii)
}
```

**v2** — use program options instead:
```go
tm := teatest.NewTestModel(t, initialModel(),
    teatest.WithInitialTermSize(80, 24),
    tea.WithColorProfile(colorprofile.Ascii),
)
```

If using golden files, add a `.gitattributes` to prevent line-ending corruption:
```
*.golden -text
```

### Creating a Test Model

```go
tm := teatest.NewTestModel(t, initialModel(),
    teatest.WithInitialTermSize(80, 24),
)
```

Always set a fixed terminal size for reproducible output.

### Three Testing Approaches

**1. Golden file testing — validate full rendered output**

```go
func TestView(t *testing.T) {
    tm := teatest.NewTestModel(t, initialModel(),
        teatest.WithInitialTermSize(80, 24),
    )

    // v1: tm.Send(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune("hello")})
    // v2:
    tm.Send(tea.KeyPressMsg{Code: 'h', Text: "h"})

    tm.Send(tea.KeyPressMsg{Code: tea.KeyEnter}) // v2 (v1: tea.KeyMsg{Type: tea.KeyEnter})

    // Cause the program to quit
    tm.Send(tea.KeyPressMsg{Code: 'q', Text: "q"})

    tm.WaitFinished(t, teatest.WithFinalTimeout(time.Second))
    out, _ := io.ReadAll(tm.FinalOutput(t))
    teatest.RequireEqualOutput(t, out)
}
```

Golden files are stored in `testdata/TestFunctionName.golden`. Create/update them:
```
go test ./... -update
```

**2. Model state testing — assert on internal fields**

```go
func TestModelState(t *testing.T) {
    tm := teatest.NewTestModel(t, initialModel(),
        teatest.WithInitialTermSize(80, 24),
    )

    tm.Send(tea.KeyPressMsg{Code: 'q', Text: "q"}) // v2
    tm.WaitFinished(t, teatest.WithFinalTimeout(time.Second))

    fm := tm.FinalModel(t)
    m, ok := fm.(model)
    if !ok {
        t.Fatal("final model has wrong type")
    }
    if m.count != 1 {
        t.Errorf("expected count=1, got %d", m.count)
    }
}
```

**3. WaitFor — assert on intermediate output without quitting**

```go
func TestInteractiveFlow(t *testing.T) {
    tm := teatest.NewTestModel(t, initialModel(),
        teatest.WithInitialTermSize(80, 24),
    )

    tm.Send(tea.KeyPressMsg{Code: 'h', Text: "hello"}) // v2
    teatest.WaitFor(t, tm.Output(), func(bts []byte) bool {
        return bytes.Contains(bts, []byte("hello"))
    },
        teatest.WithCheckInterval(100*time.Millisecond),
        teatest.WithDuration(3*time.Second),
    )

    tm.Send(tea.KeyPressMsg{Code: tea.KeyEnter})
    teatest.WaitFor(t, tm.Output(), func(bts []byte) bool {
        return bytes.Contains(bts, []byte("submitted"))
    })

    tm.Send(tea.KeyPressMsg{Code: 'q', Text: "q"})
    tm.WaitFinished(t, teatest.WithFinalTimeout(time.Second))
}
```

Use `WaitFor` when testing multi-step interactions or async behavior (e.g., waiting for a spinner to resolve, data to load). It polls `tm.Output()` at the check interval until the predicate returns true or the duration expires.

### Sending Input

**v1:**
```go
tm.Send(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune("q")})
tm.Send(tea.KeyMsg{Type: tea.KeyEnter})
tm.Send(tea.KeyMsg{Type: tea.KeyCtrlC})
```

**v2:**
```go
tm.Send(tea.KeyPressMsg{Code: 'q', Text: "q"})
tm.Send(tea.KeyPressMsg{Code: tea.KeyEnter})
tm.Send(tea.KeyPressMsg{Code: tea.KeyTab})
tm.Send(tea.KeyPressMsg{Code: 'c', Mod: tea.ModCtrl})
```

Both versions support sending custom messages to test command results directly:
```go
tm.Send(fetchResultMsg{data: "mock data"})
```

### Tips
- Always call `tm.WaitFinished()` with a timeout to prevent tests from hanging.
- Use `FinalOutput` for snapshot/golden testing, `WaitFor` for behavior testing.
- `FinalModel` is useful for testing state logic independently of rendering.
- Send custom message types to skip slow async commands in tests — inject the result directly.

## File Organization (for scaffolded projects)

```
.
├── main.go          # Entry point, tea.NewProgram
├── model.go         # Root model, Init/Update/View
├── commands.go      # tea.Cmd functions and message types
├── styles.go        # lipgloss styles
├── keys.go          # key bindings (if using bubbles/key)
├── components/      # Child models (for larger apps)
│   ├── header.go
│   └── ...
├── Makefile
└── go.mod
```

For small apps, a single `main.go` is perfectly fine.
