//
//  Palette.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/7/23.
//

import Foundation

struct Palette: Identifiable, Codable, Hashable {
    var name: String
    var emojis: String
    var id: UUID = .init()
    
    // every time someone asks for builtins, it will make new ones.
    // so we won't get into a situation where there are 2 different PaletteStores, both using
    // builtins, and the palettes have the same ID.
    static var builtIns: [Palette] {[
        Palette(name: "Weather",
                emojis: "⚡️🌈☁️🌫️🫧💧❄️🌪️"),
        Palette(name: "Animals",
                emojis: "🐾🐥🐛🦋🐌🐞🐜🦅🪱🕷️🐍🐿️🦨"),
        Palette(name: "Nature",
                emojis: "🪵🍁🍂🍃🍄🪺🌱🌿🌵🎄🌲🌳🌴🪨🌾💐🌷🌹🥀🪻🪷🌺🌸🌼🌻"),
        Palette(name: "Other",
                emojis: "👽💀🧞‍♀️🧚‍♀️🧚🧚‍♂️🧜🏼‍♀️🚲")
    ]}
}
