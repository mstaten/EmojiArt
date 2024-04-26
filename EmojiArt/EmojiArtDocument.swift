//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/1/23.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let emojiart = UTType(exportedAs: "com.example.mstate.emojiart")
}

// view model
class EmojiArtDocument: ReferenceFileDocument {
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    static var readableContentTypes: [UTType] {
        [.emojiart]
    }
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArt(json: data)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    typealias Emoji = EmojiArt.Emoji
    
    @Published private var emojiArt = EmojiArt() {
        didSet {
            if emojiArt.background != oldValue.background {
                // if user has changed their background url
                Task {
                    await fetchBackgroundImage()
                }
            }
        }
    }
    
    @Published var background: Background = .none
    
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
    
    init() {
        
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

    // MARK: - Undo
    
    private func undoablyPerform(_ action: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(action, with: undoManager) {
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(action)
    }
    
    // MARK: - Intents
    
    func setBackground(_ url: URL?, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Set Background", with: undoManager) {
            emojiArt.background = url
        }
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Add \(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: position, size: Int(size))
        }
    }
    
    func removeEmoji(with id: Emoji.ID, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Remove", with: undoManager) {
            emojiArt.removeEmoji(with: id)
        }
    }
    
    func resizeEmojis(_ emojis: Set<Emoji.ID>, by value: CGFloat, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Resize", with: undoManager) {
            for id in emojis {
                if let emoji = emojiArt[id] {
                    emojiArt[emoji].size = Int(CGFloat(emoji.size) * value)
                }
            }
        }
    }
    
    func moveEmojis(_ emojis: Set<Emoji.ID>, by offset: CGOffset, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Move", with: undoManager) {
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
