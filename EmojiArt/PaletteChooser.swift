//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/8/23.
//

import SwiftUI

struct PaletteChooser: View {
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        HStack {
            chooser
            view(for: store.palettes[store.cursorIndex])
        }
        .clipped()
    }
    
    var chooser: some View {
        AnimatedActionButton(systemImage: "paintpalette") {
            store.nextPalette()
        }
        .contextMenu {
            AnimatedActionButton("New", systemImage: "plus") {
                store.insert(Palette(name: "Faces", emojis: "🦊🐨🐤🐭🐮😈👾💀🎃🤡"))
            }
            AnimatedActionButton("Delete", systemImage: "minus.circle", role: .destructive) {
                store.deleteCurrentPalette()
            }
        }
    }
    
    // Transitions animate the comings & goings of views, but our HStack of palettes is never coming & going.
    // We add an ID to the HStack so that it does change as the palette changes. This triggers the transition.
    func view(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojis(palette.emojis)
        }
        .id(palette.id)
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
    }
}

struct ScrollingEmojis: View {
    let emojis: [String]
    
    init(_ emojis: String) {
        self.emojis = emojis.uniqued.map(String.init)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .draggable(emoji)
                }
            }
        }
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
            .environmentObject(PaletteStore(named: "Preview"))
    }
}
