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
    
    @Published private var emojiArt = EmojiArt() {
        didSet {
            autosave()
            if emojiArt.background != oldValue.background {
                // if user has changed their background url
                Task {
                    await fetchBackgroundImage()
                }
            }
        }
    }
    
    @Published var background: Background = .none
    
    private let autosaveURL: URL = URL.documentsDirectory.appendingPathComponent("Autosaved.emojiArt")
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    // gets the bounding box for entire background image + emojis
    // works whether emojis are within background image or outside of it
    var bbox: CGRect {
        var bbox = CGRect.zero
        for emoji in emojiArt.emojis {
            bbox = bbox.union(emoji.bbox)
        }
        if let backgroundSize = background.uiImage?.size {
            bbox = bbox.union(CGRect(center: .zero, size: backgroundSize))
        }
        return bbox
    }
    
    // use saved data
    init() {
        if let data = try? Data(contentsOf: autosaveURL),
           let autosavedEmojiArt = try? EmojiArt(json: data) {
            emojiArt = autosavedEmojiArt
        }
    }
    
    private func autosave() {
        save(to: autosaveURL)
    }
    
    private func save(to url: URL) {
        do {
            let data = try emojiArt.json()
            try data.write(to: url)
        } catch let error {
            print("EmojiArtDocuent: error while saving \(error.localizedDescription)")
        }
    }
    
    // MARK: - Background Image
    
    @MainActor
    private func fetchBackgroundImage() async {
        if let url = emojiArt.background {
            background = .fetching(url)
            do {
                let image = try await fetchUIImage(from: url)
                // in case the user quickly selected multiple backgrounds, only use the most recent one
                if url == emojiArt.background {
                    background = .found(image)
                }
            } catch {
                background = .failed("Couldn't set backgound: \(error.localizedDescription)")
            }
        } else {
            background = .none
        }
    }
    
    private func fetchUIImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            throw FetchError.badImageData
        }
    }
    
    // this small enum isn't necessarily practical, it's just for lecture / example purposes
    enum FetchError: Error {
        case badImageData
    }
    
    // enum for the state machine
    enum Background {
        case none
        case fetching(URL)
        case found(UIImage)
        case failed(String)
        
        var uiImage: UIImage? {
            switch self {
            case .found(let uiImage): return uiImage
            default: return nil
            }
        }
        
        var urlBeingFetched: URL? {
            switch self {
            case .fetching(let url): return url
            default: return nil
            }
        }
        
        var isFetching: Bool { urlBeingFetched != nil }
        
        var failureReason: String? {
            switch self {
            case .failed(let reason): return reason
            default: return nil
            }
        }
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
    var bbox: CGRect {
        CGRect(
            center: position.in(nil),
            size: CGSize(width: CGFloat(size), height: CGFloat(size))
        )
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy?) -> CGPoint {
        let center = geometry?.frame(in: .local).center ?? .zero
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}
