# Timer & Reset Button Design

**Date:** 2026-03-04
**Approach:** Option A — Timer in GameViewModel

---

## Goals

- Add a countdown timer that scales with grid size and resets the board when it expires
- Add a visible reset button that restarts the entire game with a confirmation dialog

---

## GameViewModel Changes

### New properties

```swift
var timeRemaining: Double       // current countdown value
var timerIsActive: Bool = false // false during splash, win card
var timerDuration: Double { Double(gridSize * 10) }  // 20s (2×2) → 90s (9×9)
```

### New methods

**`tickTimer()`** — called every second from ContentView via Timer.publish:
- Decrements `timeRemaining` by 1
- If `timeRemaining <= 0`: calls `randomizeBoard()`, resets `timeRemaining = timerDuration`

**`resetTimer()`** — resets `timeRemaining = timerDuration`, sets `timerIsActive = true`:
- Called by `nextRound()` and `resetGame()`

### Existing method changes

- `nextRound()` — calls `resetTimer()` after `randomizeBoard()`
- `resetGame()` — calls `resetTimer()` after `resetBoard()`
- `checkForWinner()` — sets `timerIsActive = false` when winner detected
- `restoreGame()` — calls `resetTimer()` after restoring state

---

## UI Changes

### ScoreBoardView — 4th timer chip

- SF Symbol: `timer`
- Label: time formatted as `M:SS` (e.g. `"0:45"`)
- When `timeRemaining <= 10`: chip label turns `.red` + subtle pulse animation (`.scaleEffect` repeating)

### ContentView — Timer publisher

```swift
.onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
    if vm.timerIsActive { vm.tickTimer() }
}
```

### ContentView — Reset button

- Placed in the title area, right-aligned (HStack with Spacer between title and button)
- SF Symbol: `arrow.counterclockwise.circle`
- Tapping shows `.confirmationDialog`:
  - Title: "Reset Game?"
  - Message: "This will return you to Level 1, Round 1."
  - Actions: [Reset (destructive), Cancel]
- Confirming calls `withAnimation(.spring) { vm.resetGame() }`

---

## Timer Duration Table

| Level | Grid | Duration |
|-------|------|----------|
| 1 | 2×2 | 20s |
| 2 | 3×3 | 30s |
| 3 | 4×4 | 40s |
| 4 | 5×5 | 50s |
| 5 | 6×6 | 60s |
| 6 | 7×7 | 70s |
| 7 | 8×8 | 80s |
| 8 | 9×9 | 90s |

---

## Out of Scope

- Pause button
- Best-time tracking
- Timer affecting score
- Per-round timer (timer resets on each new round, not on each move)
