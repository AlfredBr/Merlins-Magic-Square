//
//  Color.extension.swift
//  Magic Square
//
//  Created by Alfred Broderick on 4/14/20.
//  Copyright © 2020 Alfred Broderick. All rights reserved.
//

import SwiftUI

extension Color
{
    static var silver  : Color { return Color(.sRGB, red: 0.7, green: 0.7, blue: 0.7) }
    static var cyan    : Color { return Color(.sRGB, red: 0.0, green: 1.0, blue: 1.0) }
    static var magenta : Color { return Color(.sRGB, red: 1.0, green: 0.0, blue: 1.0) }
    static var maroon  : Color { return Color(.sRGB, red: 0.5, green: 0.0, blue: 0.0) }
    static var olive   : Color { return Color(.sRGB, red: 0.5, green: 0.5, blue: 0.0) }
    static var lime    : Color { return Color(.sRGB, red: 0.0, green: 1.0, blue: 0.0) }
    static var teal    : Color { return Color(.sRGB, red: 0.0, green: 0.5, blue: 0.5) }
    static var gold    : Color { return Color(.sRGB, red: 0.8, green: 0.6, blue: 0.1) }
    static var navy    : Color { return Color(.sRGB, red: 0.0, green: 0.0, blue: 0.5) }
    static var systemBackground : Color { return Color(UIColor.systemBackground) }
    
    static let collection = [ 
        // -- stock colors
        //Color.black,
        //Color.white,        
        Color.gray,
        Color.red, 
        Color.green, 
        Color.blue, 
        Color.orange, 
        Color.yellow, 
        Color.pink, 
        Color.purple, 
        // -- custom colors
        Color.cyan, 
        Color.magenta, 
        Color.olive, 
        Color.lime, 
        Color.maroon,
        Color.teal, 
        Color.silver, 
        Color.gold 
    ]
}
