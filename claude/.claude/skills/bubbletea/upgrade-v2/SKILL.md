---
name: bubbletea-upgrade
description: Use this skill when migrating a BubbleTea/Lipgloss/Bubbles project from v1 to v2, or when you detect v1 import paths (github.com/charmbracelet/bubbletea, github.com/charmbracelet/lipgloss, github.com/charmbracelet/bubbles) in existing code that needs updating
---

# BubbleTea Ecosystem v1 → v2 Migration Guide

This guide covers upgrading **bubbletea**, **lipgloss**, and **bubbles** together. All three must be upgraded simultaneously — v2 bubbles requires v2 bubbletea and v2 lipgloss.

## Migration Strategy

1. Update all import paths first
2. Fix `View()` return type
3. Update key/mouse message handling
4. Replace removed commands/options with View fields
5. Update bubbles component APIs
6. Update lipgloss color and output APIs
7. Build and fix remaining compile errors

---

## 1. Import Path Changes

All packages moved to vanity domains. Do a global find-replace:

| v1 | v2 |
|----|-----|
| `github.com/charmbracelet/bubbletea` | `charm.land/bubbletea/v2` |
| `github.com/charmbracelet/lipgloss` | `charm.land/lipgloss/v2` |
| `github.com/charmbracelet/bubbles/...` | `charm.land/bubbles/v2/...` |
| `github.com/charmbracelet/lipgloss/tree` | `charm.land/lipgloss/v2/tree` |

The `runeutil` and `memoization` packages from bubbles are no longer public.

---

## 2. BubbleTea Core Changes

### View() Signature

**v1:** `View() string`
**v2:** `View() tea.View`

```go
// v2
func (m model) View() tea.View {
    v := tea.NewView("Hello, BubbleTea!")
    v.AltScreen = true
    return v
}
```

The `tea.View` struct has fields for terminal features that were previously set via options or commands:

| Field | Type | Purpose |
|-------|------|---------|
| `AltScreen` | `bool` | Enter alt screen |
| `MouseMode` | `tea.MouseMode` | Mouse input mode |
| `ReportFocus` | `bool` | Focus/blur events |
| `DisableBracketedPasteMode` | `bool` | Disable paste detection |
| `WindowTitle` | `string` | Terminal title |
| `Cursor` | `*tea.Cursor` | Cursor position/style |
| `ForegroundColor` | `color.Color` | Terminal foreground |
| `BackgroundColor` | `color.Color` | Terminal background |
| `ProgressBar` | `float64` | Native progress indicator |
| `KeyboardEnhancements` | `tea.KeyboardEnhancement` | Enhanced key input |

### Removed Program Options → View Fields

| v1 option | v2 View field |
|-----------|---------------|
| `tea.WithAltScreen()` | `v.AltScreen = true` |
| `tea.WithMouseCellMotion()` | `v.MouseMode = tea.MouseModeCellMotion` |
| `tea.WithMouseAllMotion()` | `v.MouseMode = tea.MouseModeAllMotion` |
| `tea.WithReportFocus()` | `v.ReportFocus = true` |
| `tea.WithoutBracketedPaste()` | `v.DisableBracketedPasteMode = true` |
| `tea.WithInputTTY()` | Removed (automatic) |
| `tea.WithANSICompressor()` | Removed (handled by renderer) |

### Removed Commands → View Fields

| v1 command | v2 View field |
|------------|---------------|
| `tea.EnterAltScreen` | `v.AltScreen = true` |
| `tea.ExitAltScreen` | `v.AltScreen = false` |
| `tea.EnableMouseCellMotion` | `v.MouseMode = tea.MouseModeCellMotion` |
| `tea.DisableMouse` | `v.MouseMode = tea.MouseModeNone` |
| `tea.HideCursor` | `v.Cursor = nil` |
| `tea.ShowCursor` | `v.Cursor = tea.NewCursor(x, y)` |
| `tea.SetWindowTitle(s)` | `v.WindowTitle = s` |

### Key Message Changes

`tea.KeyMsg` is now an interface. Use `tea.KeyPressMsg` (and optionally `tea.KeyReleaseMsg`):

```go
// v1
case tea.KeyMsg:
    switch msg.String() {
    case "q", "ctrl+c":
        return m, tea.Quit
    }
    if msg.Type == tea.KeyEnter { ... }
    if msg.Alt { ... }

// v2
case tea.KeyPressMsg:
    switch msg.String() {
    case "q", "ctrl+c":
        return m, tea.Quit
    }
    if msg.Code == tea.KeyEnter { ... }
    if msg.Mod.Contains(tea.ModAlt) { ... }
```

Field mapping:

| v1 | v2 |
|----|-----|
| `msg.Type` | `msg.Code` (now a `rune`) |
| `msg.Runes` | `msg.Text` (now a `string`) |
| `msg.Alt` | `msg.Mod.Contains(tea.ModAlt)` |
| `msg.String()` | `msg.String()` (still works) |

New fields: `msg.ShiftedCode`, `msg.BaseCode`, `msg.IsRepeat`, `msg.Keystroke()`.

Note: Space bar now returns `"space"` from `String()` (not `" "`), but `Code` is still `' '`.

### Paste Message Changes

Paste events are no longer part of key messages:

```go
// v1
case tea.KeyMsg:
    if msg.Paste { ... }

// v2
case tea.PasteMsg:       // contains pasted text
case tea.PasteStartMsg:  // paste began
case tea.PasteEndMsg:    // paste ended
```

### Mouse Message Changes

`tea.MouseMsg` is now an interface. Match specific event types:

```go
// v1
case tea.MouseMsg:
    if msg.Action == tea.MouseActionRelease { ... }
    x, y := msg.X, msg.Y
    if msg.Button == tea.MouseButtonLeft { ... }

// v2
case tea.MouseClickMsg:
    m := msg.Mouse()
    x, y := m.X, m.Y
    if msg.Button == tea.MouseLeft { ... }
case tea.MouseReleaseMsg:
case tea.MouseWheelMsg:
case tea.MouseMotionMsg:
```

Button renames: `MouseButtonLeft` → `MouseLeft`, `MouseButtonRight` → `MouseRight`, `MouseButtonMiddle` → `MouseMiddle`.

### API Renames

| v1 | v2 |
|----|-----|
| `tea.Sequentially()` | `tea.Sequence()` |
| `tea.WindowSize()` | `tea.RequestWindowSize()` |
| `p.Start()` | `p.Run()` |
| `p.StartReturningModel()` | `p.Run()` |

### New Program Options

| Option | Purpose |
|--------|---------|
| `tea.WithColorProfile(p)` | Force color capability (useful for tests) |
| `tea.WithWindowSize(w, h)` | Set initial terminal dimensions (useful for tests) |

---

## 3. Lipgloss Changes

### Import

```go
// v1
import "github.com/charmbracelet/lipgloss"
// v2
import "charm.land/lipgloss/v2"
```

### Color Type Change

`Color` changed from a string type to a function returning `image/color.Color`:

```go
// v1
lipgloss.Color("205")

// v2 — same syntax, different return type (image/color.Color)
lipgloss.Color("205")
lipgloss.Color("#7D56F4")
```

Methods that accepted `TerminalColor` now accept `image/color.Color`. Add `import "image/color"` if you reference the interface directly.

### Renderer Removed

| v1 | v2 |
|----|-----|
| `lipgloss.DefaultRenderer().NewStyle()` | `lipgloss.NewStyle()` |
| `renderer.NewStyle()` | `lipgloss.NewStyle()` |
| `lipgloss.SetColorProfile()` | Removed (automatic) |
| `lipgloss.ColorProfile()` | Removed |

Remove any `*lipgloss.Renderer` fields from your types.

### Output: Use Lipgloss Writers

In v2, `Style.Render()` produces full-fidelity ANSI. Color downsampling happens at output time. When used with BubbleTea v2, this is handled automatically. For standalone usage:

```go
// v1
fmt.Println(style.Render("Hello"))

// v2
lipgloss.Println(style.Render("Hello"))           // stdout
lipgloss.Fprintln(os.Stderr, style.Render("Hello")) // stderr
```

### AdaptiveColor / CompleteColor Moved

**Quick path** — use the compat package:
```go
import "charm.land/lipgloss/v2/compat"

color := compat.AdaptiveColor{
    Light: lipgloss.Color("#0000ff"),
    Dark:  lipgloss.Color("#000099"),
}
```

**Recommended path** — use new helpers:
```go
hasDark := lipgloss.HasDarkBackground(os.Stdin, os.Stdout)
lightDark := lipgloss.LightDark(hasDark)
color := lightDark(
    lipgloss.Color("#0000ff"), // light
    lipgloss.Color("#000099"), // dark
)
```

**With BubbleTea v2** — query at runtime:
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

### Whitespace Options

```go
// v1
lipgloss.Place(w, h, hPos, vPos, str,
    lipgloss.WithWhitespaceForeground(lipgloss.Color("#333")),
    lipgloss.WithWhitespaceBackground(lipgloss.Color("#000")),
)

// v2
lipgloss.Place(w, h, hPos, vPos, str,
    lipgloss.WithWhitespaceStyle(
        lipgloss.NewStyle().
            Foreground(lipgloss.Color("#333")).
            Background(lipgloss.Color("#000")),
    ),
)
```

---

## 4. Bubbles Component Changes

### Global Patterns Across Components

**Key message type:** Update all `case tea.KeyMsg:` to `case tea.KeyPressMsg:` in component Update methods.

**Width/Height fields → getter/setter methods:**
```go
// v1
m.Width = 40
w := m.Width

// v2
m.SetWidth(40)
w := m.Width()
```
Affected: filepicker, help, progress, table, textinput, viewport.

**DefaultKeyMap: variable → function:**
```go
// v1
km := textinput.DefaultKeyMap

// v2
km := textinput.DefaultKeyMap()
```
Affected: paginator, textarea, textinput.

**NewModel() aliases removed** — use `New()`:
Affected: help, list, paginator, spinner, textinput.

**DefaultStyles() now takes `isDark bool`:**
```go
// v1
styles := list.DefaultStyles()

// v2
styles := list.DefaultStyles(isDark)
```
Affected: help, list, textarea, textinput.

### Cursor

| v1 | v2 |
|----|-----|
| `model.Blink` | `model.IsBlinked` |
| `model.BlinkCmd()` | `model.Blink()` |

### Filepicker

| v1 | v2 |
|----|-----|
| `DefaultStylesWithRenderer(r)` | `DefaultStyles()` |
| `model.Height = 10` | `model.SetHeight(10)` |

### Help

| v1 | v2 |
|----|-----|
| `help.NewModel()` | `help.New()` |
| `model.Width = 80` | `model.SetWidth(80)` |
| `DefaultStyles()` | `DefaultStyles(isDark)` |

### List

| v1 | v2 |
|----|-----|
| `list.NewModel(...)` | `list.New(...)` |
| `list.DefaultStyles()` | `list.DefaultStyles(isDark)` |
| `styles.FilterPrompt` | `styles.Filter.Focused.Prompt` / `.Blurred.Prompt` |
| `styles.FilterCursor` | `styles.Filter.Cursor` |

### Paginator

| v1 | v2 |
|----|-----|
| `paginator.NewModel()` | `paginator.New()` |
| `paginator.DefaultKeyMap` (var) | `paginator.DefaultKeyMap()` (func) |
| `model.UseLeftRightKeys` | Removed — customize `KeyMap` directly |
| `model.UseUpDownKeys` | Removed — customize `KeyMap` directly |

### Progress

Most extensive changes:

```go
// v1
p.Width = 40
p.WithGradient("#ff0000", "#0000ff")
p.WithSolidFill("#ff0000")

// v2
p.SetWidth(40)
p.WithColors(lipgloss.Color("#ff0000"), lipgloss.Color("#0000ff"))
p.WithColors(lipgloss.Color("#ff0000"))  // single color = solid fill
```

| v1 | v2 |
|----|-----|
| `WithGradient(a, b string)` | `WithColors(colors ...color.Color)` |
| `WithDefaultGradient()` | `WithDefaultBlend()` |
| `WithScaledGradient(a, b)` | `WithColors(...) + WithScaled(true)` |
| `WithSolidFill(s)` | `WithColors(color)` |
| `WithColorProfile()` | Removed (automatic) |

### Spinner

| v1 | v2 |
|----|-----|
| `spinner.NewModel()` | `spinner.New()` |
| `spinner.Tick()` (package func) | `model.Tick()` (method) |

### Stopwatch

```go
// v1
sw := stopwatch.NewWithInterval(500 * time.Millisecond)
// v2
sw := stopwatch.New(stopwatch.WithInterval(500 * time.Millisecond))
```

### Table

| v1 | v2 |
|----|-----|
| `model.viewport.Width` | `model.Width()` / `model.SetWidth(w)` |
| `model.viewport.Height` | `model.Height()` / `model.SetHeight(h)` |

### Textarea

| v1 | v2 |
|----|-----|
| `textarea.DefaultKeyMap` (var) | `textarea.DefaultKeyMap()` (func) |
| `model.FocusedStyle` | `model.Styles.Focused` |
| `model.BlurredStyle` | `model.Styles.Blurred` |
| `DefaultStyles()` returns 2 values | `DefaultStyles(isDark) Styles` |
| `model.Cursor` (Model) | `model.Cursor()` (func → `*tea.Cursor`) |
| `model.SetCursor(col)` | `model.SetCursorColumn(col)` |

### Textinput

| v1 | v2 |
|----|-----|
| `textinput.DefaultKeyMap` (var) | `textinput.DefaultKeyMap()` (func) |
| `model.Width = 40` | `model.SetWidth(40)` |
| `model.Styles.Focused` | `model.Styles.Focused` |
| `model.Styles.Blurred` | `model.Styles.Blurred` |
| `DefaultStyles()` returns 2 values | `DefaultStyles(isDark) Styles` |

### Viewport

| v1 | v2 |
|----|-----|
| `model.Width = 80` | `model.SetWidth(80)` |
| `model.Height = 24` | `model.SetHeight(24)` |
| `model.YOffset = 0` | `model.SetYOffset(0)` |

---

## 5. Step-by-Step Migration Checklist

1. **Update go.mod**: `go get charm.land/bubbletea/v2 charm.land/lipgloss/v2 charm.land/bubbles/v2`
2. **Find-replace import paths** across all `.go` files
3. **Update `View()` methods**: change return type to `tea.View`, use `tea.NewView(content)`, move `WithAltScreen()`/mouse/etc. to View fields
4. **Update `tea.NewProgram()`**: remove options that moved to View fields
5. **Replace `tea.KeyMsg` with `tea.KeyPressMsg`** in all `Update()` type switches
6. **Replace `tea.MouseMsg` with specific types** (`MouseClickMsg`, etc.)
7. **Replace paste handling** (`msg.Paste` → `tea.PasteMsg`)
8. **Update bubbles constructors**: `NewModel()` → `New()`
9. **Update field access**: `.Width = x` → `.SetWidth(x)`, `.Width` → `.Width()`
10. **Update `DefaultKeyMap`** references: variable → function call
11. **Update `DefaultStyles()`** calls: add `isDark` parameter
12. **Update lipgloss**: remove Renderer usage, switch to `lipgloss.Println()` for standalone output
13. **Update AdaptiveColor/CompleteColor** usage
14. **Build and fix** remaining compilation errors
