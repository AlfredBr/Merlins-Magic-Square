//  ContentView.swift
//  Magic Square

import SwiftUI

struct ContentView: View {
    @Environment(GameViewModel.self) private var vm
    @State private var resetTapCount = 0
    @State private var showResetConfirmation = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
        .onReceive(ticker) { _ in
            guard !vm.showSplash else { return }
            vm.tickTimer()
        }
    }

    private var mainContent: some View {
        VStack(spacing: 16) {
            titleBar
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

    private var titleBar: some View {
        HStack {
            Spacer()
            titleView
            Spacer()
            resetButton
                .padding(.trailing, 16)
        }
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

    private var resetButton: some View {
        Button {
            showResetConfirmation = true
        } label: {
            Image(systemName: "arrow.counterclockwise.circle")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .confirmationDialog(
            "Reset Game?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                withAnimation(.spring) { vm.resetGame() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will return you to Level 1, Round 1.")
        }
    }
}

#Preview {
    ContentView()
        .environment(GameViewModel())
}
