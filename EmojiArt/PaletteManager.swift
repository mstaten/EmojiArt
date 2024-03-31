//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Michelle Staten on 3/27/24.
//

import SwiftUI

struct PaletteManager: View {
    let stores: [PaletteStore]
    
    @State var selectedStore: PaletteStore?
    
    var body: some View {
        NavigationSplitView {
            List(stores, selection: $selectedStore) { store in
                PaletteStoreView(store: store)
                    .tag(store)
            }
        } content: {
            if let selectedStore {
                EditablePaletteList(store: selectedStore)
            } else {
                Text("Choose a store")
            }
        } detail: {
            Text("Choose a palette")
        }
    }
}

struct PaletteStoreView: View {
    @ObservedObject var store: PaletteStore
    
    var body: some View {
        Text(store.name)
    }
}

#Preview {
    PaletteManager(stores: [PaletteStore(named: "Preview 1"), PaletteStore(named: "Preview 2")])
}
