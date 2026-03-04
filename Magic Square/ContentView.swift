//  ContentView.swift
//  Magic Square

import SwiftUI

struct ContentView: View {
    @Environment(GameViewModel.self) private var vm
    @State private var resetTapCount = 0

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

#Preview {
    ContentView()
        .environment(GameViewModel())
}
