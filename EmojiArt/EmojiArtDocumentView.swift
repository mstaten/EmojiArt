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
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            // modifying GestureState in .updating
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                if selectedEmojis.isEmpty {
                    gestureZoom = inMotionPinchScale
                }
            }
            // modifying state or model in .onEnded
            .onEnded { endedPinchScale in
                if selectedEmojis.isEmpty {
                    zoom *= endedPinchScale
                }
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { inMotionDragGestureValue, gesturePan, _ in
                if selectedEmojis.isEmpty {
                    gesturePan = inMotionDragGestureValue.translation
                }
            }
            .onEnded { endedDragGestureValue in
                if selectedEmojis.isEmpty {
                    pan += endedDragGestureValue.translation
                }
            }
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
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
            Text(emoji.string)
                .font(emoji.font)
                .selected(selectedEmojis.contains(emoji.id))
                .position(emoji.position.in(geometry))
                .onTapGesture {
                    tapEmoji(with: emoji.id)
                }
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
    
    private let paletteEmojiSize: CGFloat = 40
}

struct EmojiArtDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
            .environmentObject(PaletteStore(named: "Preview"))
    }
}
