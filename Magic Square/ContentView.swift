// ContentView.swift — stub (will be rewritten in Task 9)
import SwiftUI

struct ContentView: View {
    @Environment(GameViewModel.self) private var vm
    var body: some View {
        VStack {
            ScoreBoardView()
            GridView()
            WinnerView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(GameViewModel())
    }
}
