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
