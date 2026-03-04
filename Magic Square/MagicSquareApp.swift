// MagicSquareApp.swift — stub
import SwiftUI
@main struct MagicSquareApp: App {
    @State private var viewModel = GameViewModel()
    var body: some Scene {
        WindowGroup { ContentView().environment(viewModel) }
    }
}
