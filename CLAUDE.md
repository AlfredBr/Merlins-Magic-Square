# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Merlin's Magic Square is an iOS game (SwiftUI/Swift) recreating the classic "Lights Out" puzzle mechanic from the 1970s Merlin toy. Tapping a square toggles it and its four adjacent neighbors. The goal is to color all squares to advance through 8 difficulty levels (2×2 up to 9×9 grid).

## Build & Run

Open in Xcode — there is no package manager or build script:

```bash
open "Magic Square.xcodeproj"
```

Command-line build:
```bash
xcodebuild -scheme "Magic Square" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16'
```

No external dependencies. Requires Xcode 12+ targeting iOS 13+.

## Architecture

All game logic lives in a single `ContentView.swift` (SwiftUI View). There is no separate view model — game state is managed via `@State` properties directly on the view:

- `gsLevel` / `gsRound` / `gsMove` — progression counters
- `gsBoxes` — flat array representing the grid (1 = lit, 0 = unlit)
- `gsIsWinner` / `gsShowSplash` — UI state flags

Key functions in `ContentView.swift`:
- `flip(x:y:)` — core mechanic: toggles target square and its 4 neighbors
- `flipN(x:y:)` — bounds-safe single-square toggle
- `checkForWinner()` — detects when all squares are lit
- `nextRound()` — advances round/level, resets board, picks new random color

Game state is persisted to `UserDefaults` (keys defined in `GameState.swift`'s `Key` struct). The `xGameState` class in that file is unused/deprecated.

**Color system** (`Color.extension.swift`): `Color.collection` is a shuffled array of 18 named colors cycled per round.

**Responsive sizing** (`Screen.extension.swift`): Box sizes are hard-coded per grid size based on `Screen.width` to support iPhone and iPad.

## Notable Behaviors

- Splash screen shows for 2 seconds on launch (`gsShowSplash`)
- Tapping the logo 10+ times triggers a hidden reset
- iPad supports all orientations; iPhone is portrait-only
- Dark mode adapts automatically via SwiftUI environment
