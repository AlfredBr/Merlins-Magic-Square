# Timer & Reset Button Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a scaling countdown timer (resets board on expiry) and a visible reset button (restarts the game with confirmation) to Merlin's Magic Square.

**Architecture:** All timer state lives in `GameViewModel` (`timeRemaining`, `timerIsActive`). `ContentView` drives the countdown via `Timer.publish` and `.onReceive`. `ScoreBoardView` gains a 4th chip showing the countdown in M:SS format that turns red and pulses below 10 seconds. A reset button in the title bar shows a `.confirmationDialog` before calling `vm.resetGame()`.

**Tech Stack:** Swift 5.9, SwiftUI, iOS 17+, `@Observable`, `Timer.publish`

**Design doc:** `docs/plans/2026-03-04-timer-reset-design.md`

---

## Prerequisites

Build must pass before starting:
```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,id=396682C3-A29F-4CF7-BE15-C5DB0D4A9730' build 2>&1 | tail -3
```
Expected: `** BUILD SUCCEEDED **`

---

### Task 1: Add timer state and logic to GameViewModel

**Files:**
- Modify: `Magic Square/GameViewModel.swift`

**Step 1: Add timer properties**

Open `Magic Square/GameViewModel.swift`. After the `showSplash` property (around line 28), add:

```swift
var timeRemaining: Double = 20
var timerIsActive: Bool = false
```

After the `isGameOver` computed property, add:

```swift
var timerDuration: Double { Double(gridSize * 10) }

var timerIsUrgent: Bool { timeRemaining <= 10 }

var timerLabel: String {
    let total = max(0, Int(timeRemaining))
    let minutes = total / 60
    let seconds = total % 60
    return String(format: "%d:%02d", minutes, seconds)
}
```

**Step 2: Add `tickTimer()` method**

Add after `levelLabel`:

```swift
func tickTimer() {
    guard timerIsActive, !isWinner else { return }
    timeRemaining -= 1
    if timeRemaining <= 0 {
        randomizeBoard()
        timeRemaining = timerDuration
    }
}
```

**Step 3: Add `resetTimer()` method**

```swift
func resetTimer() {
    timeRemaining = timerDuration
    timerIsActive = true
}
```

**Step 4: Wire `resetTimer()` into existing methods**

In `nextRound()`, add `resetTimer()` after `saveGame()`:
```swift
func nextRound() {
    guard !isGameOver else { return }
    round += 1
    if isLevelOver {
        level += 1
        round = 1
    }
    resetBoard()
    randomizeBoard()
    move = 0
    saveGame()
    resetTimer()   // ← add this
}
```

In `resetGame()`, add `resetTimer()` after `saveGame()`:
```swift
func resetGame() {
    level = 1
    round = 1
    move = 0
    resetBoard()
    saveGame()
    resetTimer()   // ← add this
}
```

In `checkForWinner()`, pause the timer when the player wins:
```swift
func checkForWinner() {
    let won = (0 ..< gridSize * gridSize).allSatisfy { boxes[$0] }
    if won {
        isWinner = true
        timerIsActive = false   // ← add this
    }
    saveGame()
}
```

In `restoreGame()`, start the timer after restoring:
```swift
func restoreGame() {
    level = max(1, storedLevel)
    move  = max(0, storedMove)
    round = max(1, storedRound)
    boxes = UserDefaults.standard.array(forKey: Key.gameBoxes) as? [Bool]
          ?? [Bool](repeating: false, count: 81)
    resetTimer()   // ← add this
}
```

**Step 5: Build**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,id=396682C3-A29F-4CF7-BE15-C5DB0D4A9730' build 2>&1 | tail -3
```
Expected: `** BUILD SUCCEEDED **`

**Step 6: Commit**

```bash
git add "Magic Square/GameViewModel.swift"
git commit -m "feat: add countdown timer state and logic to GameViewModel"
```

---

### Task 2: Add timer chip to ScoreBoardView

**Files:**
- Modify: `Magic Square/Views/ScoreBoardView.swift`

**Step 1: Replace ScoreBoardView body**

Replace the entire file content with:

```swift
//  ScoreBoardView.swift
//  Magic Square

import SwiftUI

struct ScoreBoardView: View {
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            scoreChip(icon: "grid.3x3", label: vm.levelLabel)
            Spacer()
            scoreChip(icon: "arrow.counterclockwise", label: "Round \(vm.round)")
            Spacer()
            scoreChip(icon: "hand.tap", label: "\(vm.move) moves")
            Spacer()
            timerChip
            Spacer()
        }
        .font(.footnote.weight(.medium))
    }

    private var timerChip: some View {
        Label(vm.timerLabel, systemImage: "timer")
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(.thinMaterial, in: Capsule())
            .foregroundStyle(vm.timerIsUrgent ? Color.red : Color.primary)
            .scaleEffect(vm.timerIsUrgent ? 1.05 : 1.0)
            .animation(
                vm.timerIsUrgent
                    ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                    : .default,
                value: vm.timerIsUrgent
            )
    }

    private func scoreChip(icon: String, label: String) -> some View {
        Label(label, systemImage: icon)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(.thinMaterial, in: Capsule())
    }
}
```

**Step 2: Build**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,id=396682C3-A29F-4CF7-BE15-C5DB0D4A9730' build 2>&1 | tail -3
```
Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "Magic Square/Views/ScoreBoardView.swift"
git commit -m "feat: add timer chip to ScoreBoardView with urgency pulse"
```

---

### Task 3: Wire timer publisher and reset button into ContentView

**Files:**
- Modify: `Magic Square/ContentView.swift`

**Step 1: Replace ContentView.swift**

Replace the entire file with:

```swift
//  ContentView.swift
//  Magic Square

import SwiftUI

struct ContentView: View {
    @Environment(GameViewModel.self) private var vm
    @State private var resetTapCount = 0
    @State private var showResetConfirmation = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if vm.showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: vm.showSplash)
        .sensoryFeedback(.impact(weight: .light), trigger: vm.move)
        .sensoryFeedback(.success, trigger: vm.isWinner)
        .onReceive(ticker) { _ in
            vm.tickTimer()
        }
    }

    private var mainContent: some View {
        VStack(spacing: 16) {
            titleBar
            ScoreBoardView()
            ZStack {
                GridView()
                    .padding(.horizontal, 12)
                WinnerView()
            }
            Spacer()
        }
        .padding(.top)
    }

    private var titleBar: some View {
        HStack {
            Spacer()
            titleView
            Spacer()
            resetButton
                .padding(.trailing, 16)
        }
    }

    private var titleView: some View {
        Button {
            resetTapCount += 1
            if resetTapCount >= 10 {
                resetTapCount = 0
                withAnimation { vm.resetGame() }
            }
        } label: {
            VStack(spacing: 2) {
                Text("Merlin's")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text("Magic Square")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }

    private var resetButton: some View {
        Button {
            showResetConfirmation = true
        } label: {
            Image(systemName: "arrow.counterclockwise.circle")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .confirmationDialog(
            "Reset Game?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                withAnimation(.spring) { vm.resetGame() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will return you to Level 1, Round 1.")
        }
    }
}

#Preview {
    ContentView()
        .environment(GameViewModel())
}
```

**Step 2: Build**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,id=396682C3-A29F-4CF7-BE15-C5DB0D4A9730' build 2>&1 | tail -3
```
Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "Magic Square/ContentView.swift"
git commit -m "feat: wire timer publisher and reset button with confirmation dialog"
```

---

### Task 4: Final verification

**Step 1: Clean build**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,id=396682C3-A29F-4CF7-BE15-C5DB0D4A9730' clean build 2>&1 | tail -3
```
Expected: `** BUILD SUCCEEDED **`

**Step 2: Install and run**

```bash
APP_PATH=$(xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,id=396682C3-A29F-4CF7-BE15-C5DB0D4A9730' \
  -showBuildSettings 2>/dev/null | grep " BUILT_PRODUCTS_DIR" | head -1 | awk '{print $3}') \
&& xcrun simctl install 396682C3-A29F-4CF7-BE15-C5DB0D4A9730 "$APP_PATH/Magic Square.app" \
&& xcrun simctl launch 396682C3-A29F-4CF7-BE15-C5DB0D4A9730 AlfredBr.Magic-Square
```

**Step 3: Verify checklist**

- [ ] Timer chip appears in score bar (4th chip, right side)
- [ ] Timer counts down each second
- [ ] Timer chip turns red and pulses when ≤ 10 seconds remain
- [ ] Timer hitting 0 scrambles the board and restarts (same round)
- [ ] Timer duration is 20s on level 1 (2×2), increases by 10s per level
- [ ] Timer pauses when win card is shown
- [ ] Timer restarts when Continue is tapped
- [ ] Reset button (↺) appears to the right of the title
- [ ] Tapping reset shows confirmation dialog
- [ ] Confirming resets to Level 1, Round 1 with fresh timer
- [ ] Cancelling dismisses dialog without any change
- [ ] Game state persists correctly after force-quit and relaunch

**Step 4: Commit**

```bash
git commit --allow-empty -m "chore: timer and reset button complete"
```
