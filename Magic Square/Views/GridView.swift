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
                                    vm.flip(x, y)
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
