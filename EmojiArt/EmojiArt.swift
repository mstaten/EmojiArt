//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/1/23.
//

import Foundation

struct EmojiArt: Codable {
    var background: URL?
    private(set) var emojis = [Emoji]()
    private var uniqueEmojiID: Int = 0
    
    init() {
        
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArt.self, from: json)
    }
    
    func json() throws -> Data {
        let encoded = try JSONEncoder().encode(self)
        return encoded
    }
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        uniqueEmojiID += 1
        emojis.append(Emoji(string: emoji, position: position, size: size, id: uniqueEmojiID))
    }
    
    mutating func removeEmoji(with id: Emoji.ID) {
        if let index = index(of: id) {
            emojis.remove(at: index)
        }
    }
    
    @inlinable public subscript(id: Emoji.ID) -> Emoji? {
        if let index = index(of: id) {
            return emojis[index]
        } else {
            return nil
        }
    }

    @inlinable public subscript(emoji: Emoji) -> Emoji {
        get {
            if let index = index(of: emoji.id) {
                return emojis[index]
            } else {
                return emoji
            }
        }
        set {
            if let index = index(of: emoji.id) {
                emojis[index] = newValue
            }
        }
    }
    
    private func index(of id: Emoji.ID) -> Int? {
        emojis.firstIndex(where: { $0.id == id })
    }

    struct Emoji: Identifiable, Codable {
        let string: String
        var position: Position
        var size: Int
        
        var id: Int
        
        struct Position: Codable {
            var x: Int
            var y: Int
            static let zero = Self(x: 0, y: 0)
        }
    }
}
