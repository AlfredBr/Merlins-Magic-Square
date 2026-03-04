//  Color.extension.swift
//  Magic Square

import SwiftUI

extension Color {
    static let silver  = Color(.sRGB, red: 0.7, green: 0.7, blue: 0.7)
    static let cyan    = Color(.sRGB, red: 0.0, green: 1.0, blue: 1.0)
    static let magenta = Color(.sRGB, red: 1.0, green: 0.0, blue: 1.0)
    static let maroon  = Color(.sRGB, red: 0.5, green: 0.0, blue: 0.0)
    static let olive   = Color(.sRGB, red: 0.5, green: 0.5, blue: 0.0)
    static let lime    = Color(.sRGB, red: 0.0, green: 1.0, blue: 0.0)
    static let teal    = Color(.sRGB, red: 0.0, green: 0.5, blue: 0.5)
    static let gold    = Color(.sRGB, red: 0.8, green: 0.6, blue: 0.1)
    static let navy    = Color(.sRGB, red: 0.0, green: 0.0, blue: 0.5)

    static let collection: [Color] = [
        .gray, .red, .green, .blue, .orange, .yellow, .pink, .purple,
        .cyan, .magenta, .olive, .lime, .maroon, .teal, .silver, .gold
    ]
}
