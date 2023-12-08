//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/1/23.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var defaultDocument: EmojiArtDocument = .init()
    @StateObject var paletteStore: PaletteStore = .init(named: "Main")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: defaultDocument)
                .environmentObject(paletteStore)
        }
    }
}
