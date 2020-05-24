//
//  GameState.swift
//  Magic Square
//
//  Created by Alfred Broderick on 4/14/20.
//  Copyright © 2020 Alfred Broderick. All rights reserved.
//

import Foundation

struct Key
{
    static let gameMoveNumber  = "gameMoveNumber"
    static let gameLevelNumber = "gameLevelNumber"
    static let gameRoundNumber = "gameRoundNumber"
    static let initialized     = "initialized"
    static let gameBoxes       = "gameBoxes"
}

class xGameState : ObservableObject
{
    @Published var Initialized : Bool = UserDefaults.standard.bool(forKey: Key.initialized)
    {
        didSet
        {
            UserDefaults.standard.set(self.Initialized, forKey: Key.initialized)
        }
    }

    @Published var Level : Int = UserDefaults.standard.integer(forKey: Key.gameLevelNumber)
    {
        didSet
        {
            UserDefaults.standard.set(self.Level, forKey: Key.gameLevelNumber)
        }
    }

    @Published var Move : Int = UserDefaults.standard.integer(forKey: Key.gameMoveNumber)
    {
        didSet
        {
            UserDefaults.standard.set(self.Move, forKey: Key.gameMoveNumber)
        }
    }

    @Published var Round : Int = UserDefaults.standard.integer(forKey: Key.gameRoundNumber)
    {
        didSet
        {
            UserDefaults.standard.set(self.Round, forKey: Key.gameRoundNumber)
        }
    }

    @Published var Sweet : Int = UserDefaults.standard.integer(forKey: "sweet")
    {
        didSet
        {
            UserDefaults.standard.set(self.Sweet, forKey: "sweet")
        }
    }

    func Reset()
    {
        print("gameState.Reset()")
        Initialized = true
        Level = 1
        Move = 1
        Round = 1
    }
}
