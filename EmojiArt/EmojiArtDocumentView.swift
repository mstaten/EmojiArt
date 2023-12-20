//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/1/23.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    
    @ObservedObject var document: EmojiArtDocument
    @EnvironmentObject var store: PaletteStore
    @State var selectedEmojis: Set<Emoji.ID> = .init()
    
    // MARK: Gesture vars
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    @State private var isZoomingOnSelection: Bool = false
    @State private var movingEmojiID: Emoji.ID? = nil
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    @GestureState private var gestureMoveEmojis: CGOffset = .zero
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            // modifying GestureState in .updating
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                gestureZoom = inMotionPinchScale
            }
            .onChanged {_ in
                if !selectedEmojis.isEmpty && !isZoomingOnSelection {
                    isZoomingOnSelection = true
                }
            }
            // modifying state or model in .onEnded
            .onEnded { endedPinchScale in
                if selectedEmojis.isEmpty {
                    zoom *= endedPinchScale
                } else {
                    document.resizeEmojis(selectedEmojis, by: endedPinchScale)
                }
                isZoomingOnSelection = false
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { inMotionDragGestureValue, gesturePan, _ in
                gesturePan = inMotionDragGestureValue.translation
            }
            .onEnded { endedDragGestureValue in
                pan += endedDragGestureValue.translation
            }
    }
    
    private func moveEmojisGesture(_ emojis: Set<Emoji.ID>) -> some Gesture {
        DragGesture()
            .updating($gestureMoveEmojis) { inMotionDragGestureValue, gestureMoveEmojis, _ in
                gestureMoveEmojis = inMotionDragGestureValue.translation
            }
            .onChanged {_ in
                if emojis.count == 1 && movingEmojiID == nil {
                    movingEmojiID = emojis.first
                }
            }
            .onEnded { endedDragGestureValue in
                document.moveEmojis(emojis, by: endedDragGestureValue.translation)
                movingEmojiID = nil
            }
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            HStack(spacing: 0) {
                PaletteChooser()
                    .padding(.trailing)
                    .scrollIndicators(.hidden)
                Image(systemName: "trash")
                    .onTapGesture(perform: removeEmojis)
            }
            .font(.system(size: paletteEmojiSize))
            .padding(.horizontal)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(zoom * (isZoomingOnSelection ? 1 : gestureZoom))
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                return drop(sturldatas, at: location, in: geometry)
            }
        }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background)
            .position(Emoji.Position.zero.in(geometry))
            .onTapGesture(perform: deselectAll)
        ForEach(document.emojis) { emoji in
            drawnEmoji(emoji, in: geometry)
        }
    }
    
    @ViewBuilder
    private func drawnEmoji(_ emoji: Emoji, in geometry: GeometryProxy) -> some View {
        let isSelected: Bool            = selectedEmojis.contains(emoji.id)
        let showSelectedState: Bool     = isZoomingOnSelection ? false : isSelected
        let moveThisEmoji: Bool         = (movingEmojiID != nil) ? movingEmojiID == emoji.id : isSelected
        let emojisToMove: Set<Emoji.ID> = isSelected ? selectedEmojis : [emoji.id]
        
        Text(emoji.string)
            .font(emoji.font)
            .border(.yellow.opacity(showSelectedState ? 1 : 0), width: showSelectedState ? 2 : 0 )
            .scaleEffect(isSelected ? gestureZoom : 1)
            .offset(moveThisEmoji ? gestureMoveEmojis : .zero)
            .position(emoji.position.in(geometry))
            .gesture(moveEmojisGesture(emojisToMove))
            .onTapGesture {
                tapEmoji(with: emoji.id)
            }
    }
    
    private func drop(_ sturldatas: [Sturldata], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        // just in case array is empty
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url)
            case .string(let emoji):
                document.addEmoji(
                    emoji,
                    at: emojiPosition(at: location, in: geometry),
                    size: paletteEmojiSize / zoom
                )
            default:
                break
            }
            return true
        }
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        return Emoji.Position(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
    }
    
    // MARK: - Selection & Deselection
    
    private func tapEmoji(with id: Int) {
        if selectedEmojis.contains(id) {
            selectedEmojis.remove(id)
        } else {
            _ = selectedEmojis.insert(id)
        }
    }
    
    private func deselectAll() {
        if !selectedEmojis.isEmpty {
            selectedEmojis = []
        }
    }
    
    private func removeEmojis() {
        for (_, id) in selectedEmojis.enumerated() {
            document.removeEmoji(with: id)
            selectedEmojis.remove(id)
        }
    }
    
    private let paletteEmojiSize: CGFloat = 40
}

struct EmojiArtDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
            .environmentObject(PaletteStore(named: "Preview"))
    }
}
