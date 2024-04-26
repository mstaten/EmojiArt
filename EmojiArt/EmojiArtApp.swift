//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/1/23.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var paletteStore: PaletteStore = .init(named: "Main")
    
    var body: some Scene {
        DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
            EmojiArtDocumentView(document: config.document)
                .environmentObject(paletteStore)
        }
    }
}
