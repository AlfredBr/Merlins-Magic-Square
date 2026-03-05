//  ScoreBoardView.swift
//  Magic Square

import SwiftUI

struct ScoreBoardView: View {
    @Environment(GameViewModel.self) private var vm
    @State private var pulseScale: CGFloat = 1.0

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
        .onChange(of: vm.timerIsUrgent) { _, isUrgent in
            if isUrgent {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    pulseScale = 1.05
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    pulseScale = 1.0
                }
            }
        }
    }

    private var timerChip: some View {
        Label(vm.timerLabel, systemImage: "timer")
            .contentTransition(.identity)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(.thinMaterial, in: Capsule())
            .foregroundStyle(vm.timerIsUrgent ? Color.red : Color.primary)
            .scaleEffect(pulseScale)
    }

    private func scoreChip(icon: String, label: String) -> some View {
        Label(label, systemImage: icon)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(.thinMaterial, in: Capsule())
    }
}
