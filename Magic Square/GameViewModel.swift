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
