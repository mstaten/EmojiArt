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
    @StateObject var store2: PaletteStore = .init(named: "Alternate")
    @StateObject var store3: PaletteStore = .init(named: "Special")
    
    var body: some Scene {
        WindowGroup {
//            PaletteManager(
//                stores: [paletteStore, store2, store3]
//            )
            EmojiArtDocumentView(document: defaultDocument)
                .environmentObject(paletteStore)
        }
    }
}
