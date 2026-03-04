//  SplashView.swift
//  Magic Square

import SwiftUI

struct SplashView: View {
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 40) {
                Spacer()
                VStack(spacing: 24) {
                    Text("Merlin's\nMagic Square")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text("A Lights Out puzzle game")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Link("Privacy Policy",
                     destination: URL(string: "https://raw.githubusercontent.com/AlfredBr/merlins-magic-square/master/PRIVACY.md")!)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 20)
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    vm.showSplash = false
                    vm.restoreGame()
                }
            }
        }
    }
}
