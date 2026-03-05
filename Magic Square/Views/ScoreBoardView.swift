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
