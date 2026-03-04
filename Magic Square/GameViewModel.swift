// GameViewModel.swift — stub
import SwiftUI
import Observation
@Observable class GameViewModel {
    var level = 1; var round = 1; var move = 0
    var boxes = [Bool](repeating: false, count: 81)
    var isWinner = false; var showSplash = true
    var gridSize: Int { level + 1 }
    var fillColor: Color { .blue }
    var isLastRoundOfLevel: Bool { false }
    var isGameOver: Bool { false }
    func levelLabel() -> String { "\(level+1)×\(level+1)" }
    func flip(_ x: Int, _ y: Int) {}
    func nextRound() {}
    func resetGame() {}
    func restoreGame() {}
    func saveGame() {}
}
