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
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: defaultDocument)
        }
    }
}
