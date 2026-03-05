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
    var timeRemaining: Double = 20
    var timerIsActive: Bool = false
    var resetCount: Int = 0       // increments on every board scramble; views observe for flash

    // MARK: - Computed
    var gridSize: Int { level + 1 }

    var roundsInLevel: Int { maxRoundsPerLevel - level + 1 }
    var isLevelOver: Bool { round > roundsInLevel }
    var isLastRoundOfLevel: Bool { round >= roundsInLevel }
    var isGameOver: Bool { level >= maxGameLevel }

    var timerDuration: Double { Double(gridSize * 10) }

    var timerIsUrgent: Bool { timeRemaining <= 10 }

    var timerLabel: String {
        let total = max(0, Int(timeRemaining))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // Stable shuffle per-session so fillColor doesn't flicker on every redraw
    private let shuffledColors = Color.collection.shuffled()

    var fillColor: Color {
        let colorIndex = max(0, round - 1) % colors.count
        return isLastRoundOfLevel
            ? shuffledColors[colorIndex]
            : colors[colorIndex]
    }

    var winnerColor: Color {
        let colorIndex = max(0, level - 1) % colors.count
        return isWinner ? colors[colorIndex] : Color(.systemBackground)
    }

    var levelLabel: String {
        let n = level + 1
        return "\(n)×\(n)"
    }

    func tickTimer() {
        guard timerIsActive, !isWinner else { return }
        timeRemaining -= 1
        if timeRemaining <= 0 {
            randomizeBoard()
            timeRemaining = timerDuration
        }
    }

    func resetTimer() {
        timeRemaining = timerDuration
        timerIsActive = true
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
        if won {
            isWinner = true
            timerIsActive = false
        }
        saveGame()
    }

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
        resetTimer()
    }

    func resetGame() {
        level = 1
        round = 1
        move = 0
        resetBoard()
        saveGame()
        resetTimer()
    }

    func resetBoard() {
        isWinner = false
        boxes = [Bool](repeating: false, count: 81)
    }

    func randomizeBoard() {
        resetBoard()
        resetCount += 1
        guard round > 1 else { return }
        move = 0
        for _ in 0 ..< 2 {
            let rx = Int.random(in: 0 ..< gridSize)
            let ry = Int.random(in: 0 ..< gridSize)
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
        resetTimer()
    }
}
