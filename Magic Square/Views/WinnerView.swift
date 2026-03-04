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
                 ? "\(vm.levelLabel)\nCompleted!"
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
