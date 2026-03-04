# Merlin's Magic Square — Modernization Design

**Date:** 2026-03-04
**Approach:** Option A — Incremental Refactor
**Target:** iOS 17+, Swift 5.9, SwiftUI

---

## Goals

- Extract game logic from the View into a proper `@Observable` ViewModel
- Adopt `@main` App lifecycle (delete AppDelegate + SceneDelegate)
- Replace deprecated APIs (`UIScreen.main`, `.animation(.default)`, manual UserDefaults)
- Add haptic feedback, spring animations, and accessibility labels
- Modernize the UI to match current iOS design conventions

---

## Architecture

### GameViewModel (`@Observable`)

Owns all game state and logic. `ContentView` reads from it and forwards user actions.

**Properties:**
- `level: Int` — current level (1–8), grid is `(level+1) x (level+1)`
- `round: Int` — current round within the level
- `move: Int` — move counter for the current round
- `boxes: [Bool]` — 81-element flat array representing the 9×9 max grid
- `isWinner: Bool` — true when all cells in the active grid are lit
- `isGameOver: Bool` — true when level 8 is completed
- `showSplash: Bool` — controls 2-second splash screen

**Persistence:** `@AppStorage` for `level`, `round`, `move`. `boxes` continues using `UserDefaults` directly (Array not directly `@AppStorage`-compatible).

**Methods:**
- `flip(x:y:)` — core mechanic, toggles target + 4 neighbors, increments move, checks for winner
- `flipN(x:y:)` — bounds-safe single-cell toggle
- `checkForWinner()` — scans active grid, sets `isWinner`
- `nextRound()` — advances round/level, randomizes board
- `resetGame()` — full reset to level 1 round 1
- `randomizeBoard()` — applies random flips to create a solvable starting state

**Computed:**
- `gridSize: Int` — `level + 1`
- `fillColor: Color` — color for lit cells, cycles through palette per round
- `roundsInLevel: Int`, `isLevelOver: Bool`, `isLastRoundOfLevel: Bool`

### ContentView

Pure layout. Receives `GameViewModel` via `@Environment`. Composes subviews. No game logic.

### Subviews

| File | Purpose |
|------|---------|
| `MagicSquareApp.swift` | `@main` entry point, injects ViewModel into environment |
| `GameViewModel.swift` | All game state and logic |
| `ContentView.swift` | Root layout composition |
| `Views/SplashView.swift` | 2-second splash with logo and links |
| `Views/GridView.swift` | The interactive cell grid |
| `Views/ScoreBoardView.swift` | Level / Round / Moves HStack |
| `Views/WinnerView.swift` | Win and Game Over overlays |
| `Extensions/Color.extension.swift` | Custom color palette (remove redundant `systemBackground`) |
| `GameState.swift` | Keep `Key` struct, delete dead `xGameState` class |
| ~~`Screen.extension.swift`~~ | Deleted — replaced by `GeometryReader` |
| ~~`AppDelegate.swift`~~ | Deleted |
| ~~`SceneDelegate.swift`~~ | Deleted |

---

## UI Design

### Layout
- Title: SF Pro Display `.largeTitle` + `.bold` text, tappable for hidden reset (10 taps)
- Score bar: `HStack` of `Label(_, systemImage:)` using SF Symbols
  - `grid.3x3` for level
  - `arrow.counterclockwise` for round
  - `hand.tap` for moves
- Grid: cells sized via `GeometryReader`, 2pt gap, rounded corners

### Colors & Appearance
- Background: gradient + `.ultraThinMaterial` layer, auto light/dark
- Lit cells: round color fill + `.shadow(color: fillColor, radius: 8)`
- Unlit cells: `Color(.systemGray6)`
- Win overlay: spring-animated card with gold/silver gradient

### Animations
- Cell toggle: `withAnimation(.spring(response: 0.3, dampingFraction: 0.6))`
- Win/Game Over: `withAnimation(.spring)` overlay appearance
- Splash dismiss: `.transition(.opacity)` with explicit animation

### Haptics (iOS 17)
- `.sensoryFeedback(.impact(.light), trigger: move)` — each tap
- `.sensoryFeedback(.success, trigger: isWinner)` — win

### Accessibility
- Grid cells: `accessibilityLabel("Row \(y+1), Column \(x+1), \(isLit ? "lit" : "unlit")")`
- Buttons: `accessibilityHint` on Continue and Skip

---

## Deprecated APIs Fixed

| Old | New |
|-----|-----|
| `UIScreen.main.bounds` | `GeometryReader` |
| `.animation(.default)` | `withAnimation(.easeInOut)` / `.animation(.spring, value:)` |
| `AppDelegate` + `SceneDelegate` | `@main` SwiftUI App |
| Manual `UserDefaults` save/load | `@AppStorage` + direct UserDefaults for arrays |
| `Color.systemBackground` (manual) | `Color(.systemBackground)` or `.background` material |
| `xGameState` class | Deleted (was already unused) |
| `edgesIgnoringSafeArea` | `.ignoresSafeArea()` |

---

## Out of Scope

- Game rule changes
- Sound effects (AVFoundation adds complexity, can be added later)
- SwiftData migration (UserDefaults is sufficient for this data size)
- Undo functionality
- iCloud sync
