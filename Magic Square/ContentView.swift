//
//  ContentView.swift
//
//  Magic Square (based on Lights Out) from Merlin by Parker Brothers
//  http://www.theelectronicwizard.com
//
//  SwiftUI version created by Caden and Alfred Broderick on 4/12/20.
//  Copyright © 2020 Caden and Alfred Broderick. All rights reserved.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        ZStack {
            Color.primary.edgesIgnoringSafeArea(.all)
            VStack {
                Image("MerlinsMagicSquare")
                    .resizable()
                    .frame(width:(400*0.9), height: (135*0.9))
                Text("Nedac5")
            }
        }
    }
}

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let colors = Color.collection.shuffled()
    let maxRoundsPerLevel = 7 // 7
    let maxGameLevel = 7 // 7
    
    var boxSizes = [CGFloat](repeating: -1.0, count: 8)
    
    @State private var gsLevel : Int = 1
    @State private var gsMove : Int = 1
    @State private var gsRound : Int = 1
    @State private var gsBoxes = [Bool](repeating: false, count: 81)
    @State private var gsIsWinner = false
    @State private var gsShowSplash = true
    
    init()
    {
        print("init()")
        computeBoxSizes()
    }
    
    func restoreGame()
    {
        loadGame()
        printState()
        printGrid()
    }
    
    mutating func computeBoxSizes()
    {
        for i in 2 ..< 9 {
            let boxSize = round((Screen.width - CGFloat(10+i)) / CGFloat(i))
            boxSizes[i-1] = CGFloat(boxSize)
        }
    }
    
    var boxSize : CGFloat
    {
        return CGFloat(boxSizes[gsLevel])
    }
    
    var gridSize : Int
    {
        return gsLevel + 1
    }
    
    func printState()
    {
        print(" Move     = \(gsMove)")
        print(" Round    = \(gsRound) of \(roundsInLevel)")
        print(" Level    = \(gsLevel)")
        print(" isLastRoundOfLevel = \(isLastRoundOfLevel)")
        print(" gridSize = \(gridSize)x\(gridSize) [\(boxSize)]")
    }
    
    func printGrid()
    {
        var s = "printGrid() [ "
        for y in 0 ..< gridSize {
            for x in 0 ..< gridSize {
                let p = x + (y * gridSize)
                s += gsBoxes[p] ? "X" : "_"
            }
            s += " "
        }
        print("\(s)]")
    }
    
    func saveGame()
    {
        print("saveGame()")
        UserDefaults.standard.set(gsLevel, forKey: Key.gameLevelNumber)
        UserDefaults.standard.set(gsMove, forKey: Key.gameMoveNumber)
        UserDefaults.standard.set(gsRound, forKey: Key.gameRoundNumber)
        UserDefaults.standard.set(gsBoxes, forKey: Key.gameBoxes)
    }
    
    func loadGame()
    {
        print("loadGame()")
        gsLevel = max(1, UserDefaults.standard.integer(forKey: Key.gameLevelNumber))
        gsMove = max(1, UserDefaults.standard.integer(forKey: Key.gameMoveNumber))
        gsRound = max(1, UserDefaults.standard.integer(forKey: Key.gameRoundNumber))
        gsBoxes = UserDefaults.standard.array(forKey: Key.gameBoxes) as? [Bool] ?? [Bool](repeating: false, count: 81)
    }
    
    func checkForWinner()
    {
        var isWinner = true
        
        for i in 0 ..< gridSize * gridSize
        {
            let box = gsBoxes[i]
            if box == false
            {
                isWinner = false
            }
        }
        
        if (isWinner)
        {
            gsIsWinner = true
            print ("Winner!")
        }
        
        printState()
        saveGame()
    }
    
    func resetBoard()
    {
        print("resetBoard()")
        
        gsIsWinner = false
        
        for p in 0 ..< gridSize * gridSize
        {
            gsBoxes[p] = false
        }
    }
    
    func randomizeBoard()
    {
        print("randomizeBoard()")
        
        if gsRound > 1
        {
            // randomize game when gameRound > 1
            for _ in 0 ..< 2 {
                let rx = Int.random(in: 0 ..< gridSize)
                let ry = Int.random(in: 0 ..< gridSize)
                gsMove = 0
                flip(rx, ry)
            }
        }
        else
        {
            print(" no randomization")
        }
    }
    
    func resetGame()
    {
        gsRound = 1
        gsLevel = 1
        gsMove = 1
        resetBoard()
    }
    
    var roundsInLevel : Int
    {
        return maxRoundsPerLevel - gsLevel + 1
    }
    
    var isLevelOver : Bool
    {
        return gsRound > roundsInLevel
    }
    
    var isLastRoundOfLevel : Bool
    {
        return gsRound == roundsInLevel
    }
    
    var isGameOver : Bool
    {
        if gsLevel >= maxGameLevel
        {
            print("Game Over")
            return true
        }
        else
        {
            return false
        }
    }
    
    func nextRound()
    {
        if isGameOver
        {
            return
        }
        
        print("nextRound()")
        
        if isLevelOver
        {
            gsLevel += 1
            gsRound = 1
        }
        
        resetBoard()
        randomizeBoard()

        gsMove = 1
    }
    
    func flipN(_ x: Int, _ y: Int)
    {
        //print("  flipN(\(x), \(y)) \(gridSize)x\(gridSize)")
        if (x < 0 || y < 0 || x >= gridSize || y >= gridSize || gsIsWinner)
        {
            //print("   out of bounds")
            return
        }
        
        let p = x + (y * gridSize)
        gsBoxes[p].toggle()
    }
    
    func flip(_ x: Int, _ y: Int)
    {
        gsMove += 1
        
        flipN(x,   y)
        flipN(x-1, y)
        flipN(x+1, y)
        flipN(x,   y-1)
        flipN(x,   y+1)
        
        printGrid()
        checkForWinner()
    }
    
    var schemeSymbol : String
    {
        return String((colorScheme == .dark) ? "moon.stars" : "sun.max")
    }
    
    var fgColor : Color
    {
        return (colorScheme == .dark) ? Color.white : Color.black
    }
    
    var bgColor : Color
    {
        return (colorScheme == .dark) ? Color.black : Color.white
    }
    
    var fillColor : Color
    {
        let colorIndex = max(0, gsRound - 1) % colors.count
        
        return isLastRoundOfLevel
                ? colors.shuffled()[colorIndex]
                : colors[colorIndex]
    }
    
    var winnerColor : Color
    {
        let colorIndex = max(0, gsLevel - 1) % colors.count
        return gsIsWinner ? colors[colorIndex] : bgColor
    }
    
    var body : some View {
        
        return
            ZStack {
                VStack (spacing: 10.0) {
                    // title
                    VStack {
                        Image("MerlinsMagicSquare")
                            .resizable()
                            .frame(width:(400*0.7), height: (135*0.7))
                    }
                    
                    // score and stats
                    HStack {
                        Spacer()
                        Text("Level \(gsLevel)").padding(5).padding(.horizontal, 8).background(Color.silver).clipShape(Capsule())
                        Spacer()
                        //Image(systemName: schemeSymbol )
                        Text("Round \(gsRound)").padding(5).padding(.horizontal, 8).background(Color.silver).clipShape(Capsule())
                        Spacer()
                        //Image(systemName: "triangle" )
                        Text("Move \(gsMove)").padding(5).padding(.horizontal, 8).background(Color.silver).clipShape(Capsule())
                        Spacer()
                    }.font(.footnote)
                    
                    // playfield
                    ZStack {
                        HStack (spacing: 2.0) {
                            ForEach(0 ..< self.gridSize, id: \.self) { x in
                                VStack (spacing: 2.0) {
                                    ForEach(0 ..< self.gridSize, id: \.self) { y in
                                        Button(action: {
                                            self.flip(x, y)
                                        }) {
                                            Rectangle() // squares
                                                .fill(self.gsBoxes[x+(y*self.gridSize)] ? self.fillColor : self.bgColor)
                                                .border(self.fgColor, width: 3)
                                                .frame(width: self.boxSize, height: self.boxSize)
                                        }
                                    }
                                }
                            }
                        }
                        .blur(radius: self.gsIsWinner ? 30.0 : 0.0)
                        // winner announcement
                        VStack {
                            Text("You Win!")
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .padding(.vertical, 30)
                                .padding(.horizontal, 20)
                                .background(Color.gold)
                                .foregroundColor(fgColor)
                                .border(fgColor, width: 3)
                                .scaleEffect(1.5)
                        }
                        .opacity(self.gsIsWinner ? 0.9 : 0.0)
                    }
                    
                    // cheater
                    HStack {
                        Button("Skip") {
                            self.gsRound += 1
                            self.nextRound()
                        }
                        Text("-")
                        Button("Reset") {
                            self.resetGame()
                        }
                    }
                    .opacity(0.0)
                    
                    // continue button
                    VStack (spacing: 10.0) {
                        Button(action: {
                            self.gsRound += 1
                            self.nextRound()
                        })
                        {
                            Text("Continue")
                                .padding(.vertical, 5).padding(.horizontal, 8)
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        }
                    }
                    .opacity(self.gsIsWinner ? 1.0 : 0.0) // hide until round is won
                    .animation(.default)
                }
                
                // splash screen
                ZStack {
                    Color.systemBackground.edgesIgnoringSafeArea(.all)
                    VStack {                   
                        Spacer()
                        VStack {
                            Image("MerlinsMagicSquare")
                                .resizable()
                                .frame(width:(400*0.7), height: (135*0.7))
                                .padding(.bottom, Screen.height/5)
                            Button("SAB3R")
                            {
                                if let url = URL(string: "https://www.youtube.com/channel/UCcj5o_04z4960aRsq1RLHTQ") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        Spacer()
                        Button("Privacy Policy")
                        {
                            if let url = URL(string: "https://raw.githubusercontent.com/AlfredBr/merlins-magic-square/master/PRIVACY.md") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }	
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        print(" hide splash screen")
                        self.gsShowSplash = false
                        self.restoreGame()
                    }
                }
                .opacity(self.gsShowSplash ? 1.0 : 0.0)
                .animation(.default)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        //LaunchView()
    }
}
