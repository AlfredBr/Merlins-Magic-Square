# Merlin's Magic Square Modernization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Incrementally refactor the 2020 SwiftUI app into a modern iOS 17+ codebase with proper architecture, no deprecated APIs, modern animations, haptics, and a polished UI.

**Architecture:** Extract all game logic from `ContentView` into a `@Observable` `GameViewModel`. Replace `AppDelegate`/`SceneDelegate` with a `@main` SwiftUI App struct. Break `ContentView` into focused subviews.

**Tech Stack:** Swift 5.9, SwiftUI, iOS 17+, `@Observable` (Observation framework), `@AppStorage`, `GeometryReader`, `sensoryFeedback`

**Design doc:** `docs/plans/2026-03-04-modernization-design.md`

---

## Prerequisites

- Open `Magic Square.xcodeproj` in Xcode before starting
- Set deployment target to iOS 17.0 in project settings (General → Minimum Deployments)
- All builds verified with: `xcodebuild -scheme "Magic Square" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' build`

---

### Task 1: Set deployment target to iOS 17

**Files:**
- Modify: `Magic Square.xcodeproj/project.pbxproj` (via Xcode UI)

**Step 1: Open project settings in Xcode**

In Xcode: click the project root in the Navigator → "Magic Square" target → General tab → Minimum Deployments → set to iOS 17.0.

**Step 2: Build to verify**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "Magic Square.xcodeproj/project.pbxproj"
git commit -m "chore: set minimum deployment target to iOS 17"
```

---

### Task 2: Create MagicSquareApp.swift and delete AppDelegate + SceneDelegate

**Files:**
- Create: `Magic Square/MagicSquareApp.swift`
- Delete: `Magic Square/AppDelegate.swift`
- Delete: `Magic Square/SceneDelegate.swift`
- Modify: `Magic Square.xcodeproj/project.pbxproj` (Xcode manages this)

**Step 1: Create `MagicSquareApp.swift`**

```swift
//  MagicSquareApp.swift
//  Magic Square

import SwiftUI

@main
struct MagicSquareApp: App {
    @State private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
```

**Step 2: Remove `@UIApplicationMain` from AppDelegate**

Since `@main` is now in `MagicSquareApp.swift`, Xcode will error if `@UIApplicationMain` also exists. Delete `AppDelegate.swift` and `SceneDelegate.swift` from the Xcode project navigator (move to Trash).

Also remove the `UISceneConfiguration` key from `Info.plist` if present:
- In Xcode, open `Info.plist` → delete the `UIApplicationSceneManifest` entry if it exists (it may not — check first).

**Step 3: Build to verify**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`

**Step 4: Commit**

```bash
git add "Magic Square/MagicSquareApp.swift"
git rm "Magic Square/AppDelegate.swift" "Magic Square/SceneDelegate.swift"
git commit -m "feat: adopt @main SwiftUI App lifecycle, remove AppDelegate/SceneDelegate"
```

---

### Task 3: Clean up GameState.swift

**Files:**
- Modify: `Magic Square/GameState.swift`

**Step 1: Delete the dead `xGameState` class, keep only the `Key` struct**

Replace the entire file with:

```swift
//  GameState.swift
//  Magic Square

import Foundation

struct Key {
    static let gameMoveNumber  = "gameMoveNumber"
    static let gameLevelNumber = "gameLevelNumber"
    static let gameRoundNumber = "gameRoundNumber"
    static let gameBoxes       = "gameBoxes"
}
```

**Step 2: Build**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "Magic Square/GameState.swift"
git commit -m "refactor: remove dead xGameState class from GameState.swift"
```

---

### Task 4: Create GameViewModel

This is the core extraction. All `@State` logic moves here.

**Files:**
- Create: `Magic Square/GameViewModel.swift`

**Step 1: Create the file**

```swift
//  GameViewModel.swift
//  Magic Square

import SwiftUI
import Observation

@Observable
class GameViewModel {
    // MARK: - Constants
    let maxRoundsPerLevel = 7
    let maxGameLevel = 8
    private let colors = Color.collection.shuffled()

    // MARK: - Persisted state
    @ObservationIgnored
    @AppStorage(Key.gameLevelNumber) private var storedLevel: Int = 1
    @ObservationIgnored
    @AppStorage(Key.gameMoveNumber)  private var storedMove: Int = 0
    @ObservationIgnored
    @AppStorage(Key.gameRoundNumber) private var storedRound: Int = 1

    // MARK: - Game state
    var level: Int = 1
    var round: Int = 1
    var move: Int = 0
    var boxes = [Bool](repeating: false, count: 81)
    var isWinner = false
    var showSplash = true

    // MARK: - Computed
    var gridSize: Int { level + 1 }

    var roundsInLevel: Int { maxRoundsPerLevel - level + 1 }
    var isLevelOver: Bool { round > roundsInLevel }
    var isLastRoundOfLevel: Bool { round >= roundsInLevel }
    var isGameOver: Bool { level >= maxGameLevel }

    var fillColor: Color {
        let colorIndex = max(0, round - 1) % colors.count
        return isLastRoundOfLevel
            ? colors.shuffled()[colorIndex]
            : colors[colorIndex]
    }

    var winnerColor: Color {
        let colorIndex = max(0, level - 1) % colors.count
        return isWinner ? colors[colorIndex] : Color(.systemBackground)
    }

    func levelLabel() -> String {
        let n = level + 1
        return "\(n)×\(n)"
    }

    // MARK: - Game actions
    func flip(_ x: Int, _ y: Int) {
        move += 1
        flipN(x,     y)
        flipN(x - 1, y)
        flipN(x + 1, y)
        flipN(x,     y - 1)
        flipN(x,     y + 1)
        checkForWinner()
    }

    private func flipN(_ x: Int, _ y: Int) {
        guard x >= 0, y >= 0, x < gridSize, y < gridSize, !isWinner else { return }
        boxes[x + y * gridSize].toggle()
    }

    func checkForWinner() {
        let won = (0 ..< gridSize * gridSize).allSatisfy { boxes[$0] }
        if won { isWinner = true }
        saveGame()
    }

    func nextRound() {
        guard !isGameOver else { return }
        if isLevelOver {
            level += 1
            round = 1
        }
        resetBoard()
        randomizeBoard()
        move = 0
        saveGame()
    }

    func resetGame() {
        level = 1
        round = 1
        move = 0
        resetBoard()
        saveGame()
    }

    func resetBoard() {
        isWinner = false
        boxes = [Bool](repeating: false, count: 81)
    }

    func randomizeBoard() {
        resetBoard()
        guard round > 1 else { return }
        for _ in 0 ..< 2 {
            let rx = Int.random(in: 0 ..< gridSize)
            let ry = Int.random(in: 0 ..< gridSize)
            move = 0
            flip(rx, ry)
        }
    }

    // MARK: - Persistence
    func saveGame() {
        storedLevel = level
        storedMove  = move
        storedRound = round
        UserDefaults.standard.set(boxes, forKey: Key.gameBoxes)
    }

    func restoreGame() {
        level = max(1, storedLevel)
        move  = max(0, storedMove)
        round = max(1, storedRound)
        boxes = UserDefaults.standard.array(forKey: Key.gameBoxes) as? [Bool]
              ?? [Bool](repeating: false, count: 81)
    }
}
```

**Step 2: Build**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **` (ContentView still compiles with its old @State — that's fine for now)

**Step 3: Commit**

```bash
git add "Magic Square/GameViewModel.swift"
git commit -m "feat: add GameViewModel with @Observable and @AppStorage"
```

---

### Task 5: Create Views folder and SplashView

**Files:**
- Create: `Magic Square/Views/SplashView.swift`

Add the `Views/` group in Xcode (right-click in Navigator → New Group → "Views"), then create the file inside it.

**Step 1: Create `SplashView.swift`**

```swift
//  SplashView.swift
//  Magic Square

import SwiftUI

struct SplashView: View {
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 40) {
                Spacer()
                VStack(spacing: 24) {
                    Text("Merlin's\nMagic Square")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text("A Lights Out puzzle game")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Link("Privacy Policy",
                     destination: URL(string: "https://raw.githubusercontent.com/AlfredBr/merlins-magic-square/master/PRIVACY.md")!)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 20)
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    vm.showSplash = false
                }
                vm.restoreGame()
            }
        }
    }
}
```

**Step 2: Build**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "Magic Square/Views/SplashView.swift"
git commit -m "feat: add SplashView as extracted subview"
```

---

### Task 6: Create ScoreBoardView

**Files:**
- Create: `Magic Square/Views/ScoreBoardView.swift`

**Step 1: Create the file**

```swift
//  ScoreBoardView.swift
//  Magic Square

import SwiftUI

struct ScoreBoardView: View {
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            scoreChip(icon: "grid.3x3", label: vm.levelLabel())
            Spacer()
            scoreChip(icon: "arrow.counterclockwise", label: "Round \(vm.round)")
            Spacer()
            scoreChip(icon: "hand.tap", label: "\(vm.move) moves")
            Spacer()
        }
        .font(.footnote.weight(.medium))
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
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "Magic Square/Views/ScoreBoardView.swift"
git commit -m "feat: add ScoreBoardView with SF Symbols and material background"
```

---

### Task 7: Create GridView

**Files:**
- Create: `Magic Square/Views/GridView.swift`

**Step 1: Create the file**

```swift
//  GridView.swift
//  Magic Square

import SwiftUI

struct GridView: View {
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 3
            let totalSpacing = spacing * CGFloat(vm.gridSize - 1)
            let cellSize = (geo.size.width - totalSpacing) / CGFloat(vm.gridSize)

            VStack(spacing: spacing) {
                ForEach(0 ..< vm.gridSize, id: \.self) { y in
                    HStack(spacing: spacing) {
                        ForEach(0 ..< vm.gridSize, id: \.self) { x in
                            let isLit = vm.boxes[x + y * vm.gridSize]
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isLit ? vm.fillColor : Color(.systemGray5))
                                .shadow(
                                    color: isLit ? vm.fillColor.opacity(0.6) : .clear,
                                    radius: isLit ? 8 : 0
                                )
                                .frame(width: cellSize, height: cellSize)
                                .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isLit)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                                        vm.flip(x, y)
                                    }
                                }
                                .accessibilityLabel("Row \(y + 1), Column \(x + 1), \(isLit ? "lit" : "unlit")")
                                .accessibilityAddTraits(.isButton)
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .blur(radius: vm.isWinner ? 20 : 0)
        .animation(.easeInOut(duration: 0.3), value: vm.isWinner)
    }
}
```

**Step 2: Build**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "Magic Square/Views/GridView.swift"
git commit -m "feat: add GridView with GeometryReader, spring animations, accessibility"
```

---

### Task 8: Create WinnerView

**Files:**
- Create: `Magic Square/Views/WinnerView.swift`

**Step 1: Create the file**

```swift
//  WinnerView.swift
//  Magic Square

import SwiftUI

struct WinnerView: View {
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        if vm.isWinner {
            ZStack {
                if vm.isGameOver {
                    gameOverCard
                } else {
                    winnerCard
                }
            }
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }

    private var winnerCard: some View {
        VStack(spacing: 20) {
            Text(vm.isLastRoundOfLevel
                 ? "\(vm.levelLabel())\nCompleted!"
                 : "Round \(vm.round)\nCompleted!")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)

            Button {
                withAnimation(.spring) {
                    vm.round += 1
                    vm.nextRound()
                }
            } label: {
                Label("Continue", systemImage: "arrow.right.circle.fill")
                    .font(.title3.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.25), in: Capsule())
                    .foregroundStyle(.white)
            }
            .accessibilityHint("Advance to the next round")
        }
        .padding(32)
        .background(
            LinearGradient(
                colors: [Color.gold, Color.gold.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .shadow(radius: 20)
        .padding(.horizontal, 24)
    }

    private var gameOverCard: some View {
        VStack(spacing: 16) {
            Text("Game\nOver!")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            Text("You completed all 8 levels!")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
            Button {
                withAnimation(.spring) {
                    vm.resetGame()
                }
            } label: {
                Label("Play Again", systemImage: "arrow.clockwise")
                    .font(.title3.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.25), in: Capsule())
                    .foregroundStyle(.white)
            }
            .accessibilityHint("Reset the game and start from level 1")
        }
        .padding(32)
        .background(
            LinearGradient(
                colors: [Color.purple, Color.blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .shadow(radius: 20)
        .padding(.horizontal, 24)
    }
}
```

**Step 2: Build**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "Magic Square/Views/WinnerView.swift"
git commit -m "feat: add WinnerView with spring transitions and Play Again button"
```

---

### Task 9: Rewrite ContentView

Replace the monolithic `ContentView.swift` with a clean layout-only view.

**Files:**
- Modify: `Magic Square/ContentView.swift`

**Step 1: Replace ContentView.swift entirely**

```swift
//  ContentView.swift
//  Magic Square

import SwiftUI

struct ContentView: View {
    @Environment(GameViewModel.self) private var vm
    @State private var resetTapCount = 0

    var body: some View {
        ZStack {
            // Background gradient
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
        .sensoryFeedback(.impact(.light), trigger: vm.move)
        .sensoryFeedback(.success, trigger: vm.isWinner)
    }

    private var mainContent: some View {
        VStack(spacing: 16) {
            titleView
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(GameViewModel())
    }
}
```

**Step 2: Build**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "Magic Square/ContentView.swift"
git commit -m "refactor: rewrite ContentView as pure layout, extract all logic to GameViewModel"
```

---

### Task 10: Update Color.extension.swift

**Files:**
- Modify: `Magic Square/Extensions/Color.extension.swift`

Move the file to an `Extensions/` group in Xcode (optional, for tidiness). Remove the redundant `systemBackground` computed property since SwiftUI now provides it natively.

**Step 1: Update the file**

```swift
//  Color.extension.swift
//  Magic Square

import SwiftUI

extension Color {
    static let silver  = Color(.sRGB, red: 0.7, green: 0.7, blue: 0.7)
    static let cyan    = Color(.sRGB, red: 0.0, green: 1.0, blue: 1.0)
    static let magenta = Color(.sRGB, red: 1.0, green: 0.0, blue: 1.0)
    static let maroon  = Color(.sRGB, red: 0.5, green: 0.0, blue: 0.0)
    static let olive   = Color(.sRGB, red: 0.5, green: 0.5, blue: 0.0)
    static let lime    = Color(.sRGB, red: 0.0, green: 1.0, blue: 0.0)
    static let teal    = Color(.sRGB, red: 0.0, green: 0.5, blue: 0.5)
    static let gold    = Color(.sRGB, red: 0.8, green: 0.6, blue: 0.1)
    static let navy    = Color(.sRGB, red: 0.0, green: 0.0, blue: 0.5)

    static let collection: [Color] = [
        .gray, .red, .green, .blue, .orange, .yellow, .pink, .purple,
        .cyan, .magenta, .olive, .lime, .maroon, .teal, .silver, .gold
    ]
}
```

**Step 2: Delete `Screen.extension.swift`**

In Xcode Navigator: right-click `Screen.extension.swift` → Delete → Move to Trash.

**Step 3: Build**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`

**Step 4: Commit**

```bash
git add "Magic Square/Color.extension.swift"
git rm "Magic Square/Screen.extension.swift"
git commit -m "refactor: clean up Color extension, remove Screen extension"
```

---

### Task 11: Final verification

**Step 1: Full clean build**

```bash
xcodebuild -scheme "Magic Square" -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' clean build 2>&1 | tail -10
```
Expected: `** BUILD SUCCEEDED **` with no warnings about deprecated APIs.

**Step 2: Run in simulator**

In Xcode: Cmd+R. Verify:
- [ ] Splash screen appears for ~2 seconds then fades out
- [ ] Title text renders, tapping 10 times resets the game
- [ ] Score bar shows level / round / moves with SF Symbols
- [ ] Grid renders correctly for level 1 (2×2)
- [ ] Tapping a cell toggles it and its neighbors with a spring animation
- [ ] Winning a round shows the gold card with "Continue"
- [ ] Winning the final level shows the purple "Game Over" card with "Play Again"
- [ ] Dark mode works (Settings → Developer → Dark Appearance)
- [ ] Game state persists after force-quitting and relaunching the app

**Step 3: Commit**

```bash
git commit --allow-empty -m "chore: modernization complete — iOS 17+ SwiftUI refactor"
```

---

## Summary of Changes

| File | Action |
|------|--------|
| `MagicSquareApp.swift` | Created — `@main` app entry |
| `GameViewModel.swift` | Created — all game logic |
| `Views/SplashView.swift` | Created |
| `Views/ScoreBoardView.swift` | Created |
| `Views/GridView.swift` | Created |
| `Views/WinnerView.swift` | Created |
| `ContentView.swift` | Rewritten — pure layout |
| `GameState.swift` | Cleaned — removed dead class |
| `Color.extension.swift` | Cleaned — removed `systemBackground` |
| `AppDelegate.swift` | Deleted |
| `SceneDelegate.swift` | Deleted |
| `Screen.extension.swift` | Deleted |
