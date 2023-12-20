//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/1/23.
//

import SwiftUI

// view model
class EmojiArtDocument: ObservableObject {
    typealias Emoji = EmojiArt.Emoji
    
    @Published private var emojiArt = EmojiArt()
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var background: URL? {
        emojiArt.background
    }
    
    // MARK: - Intents
    
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat) {
        emojiArt.addEmoji(emoji, at: position, size: Int(size))
    }
    
    func removeEmoji(with id: Emoji.ID) {
        emojiArt.removeEmoji(with: id)
    }
    
    func resizeEmojis(_ emojis: Set<Emoji.ID>, by value: CGFloat) {
        for id in emojis {
            if let emoji = emojiArt[id] {
                emojiArt[emoji].size = Int(CGFloat(emoji.size) * value)
            }
        }
    }
    
    func moveEmojis(_ emojis: Set<Emoji.ID>, by offset: CGOffset) {
        for id in emojis {
            if let emoji = emojiArt[id] {
                let newPosition: Emoji.Position = .init(
                    x: emoji.position.x + Int(offset.width),
                    y: emoji.position.y - Int(offset.height)
                )
                emojiArt[emoji].position = newPosition
            }
        }
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}
