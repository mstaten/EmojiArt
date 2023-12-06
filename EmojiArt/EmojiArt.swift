//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/1/23.
//

import Foundation

struct EmojiArt {
    var background: URL?
    private(set) var emojis = [Emoji]()
    private var uniqueEmojiID: Int = 0
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        uniqueEmojiID += 1
        emojis.append(Emoji(string: emoji, position: position, size: size, id: uniqueEmojiID))
    }
    
    mutating func resizeEmoji(size: Int) {
        // TODO: fill this in
    }
    
    struct Emoji: Identifiable {
        let string: String
        var position: Position
        var size: Int
        
        var id: Int
        
        struct Position {
            var x: Int
            var y: Int
            
            static let zero = Self(x: 0, y: 0)
        }
    }
}
