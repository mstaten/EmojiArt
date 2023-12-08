//
//  Palette.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/7/23.
//

import Foundation

struct Palette: Identifiable {
    var name: String
    var emojis: String
    var id: UUID = .init()
    
    static let builtIns: [Palette] = [
        Palette(name: "Weather",
                emojis: "☁️⚡️"),
        Palette(name: "Animals",
                emojis: "🐾🐥🐛🦋🐌🐞🐜🦅🪱🕷️🐍🐿️🦨"),
        Palette(name: "Nature",
                emojis: "🪵🍁🍂🍃🍄🪺🌵🎄🌲🌳🌴🪨🌾💐🌷🌹🥀🪻🪷🌺🌸🌼🌻"),
        Palette(name: "Other",
                emojis: "👽💀🧞‍♀️🧚🚲")
    ]
}
