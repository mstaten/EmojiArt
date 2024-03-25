//
//  PaletteList.swift
//  EmojiArt
//
//  Created by Michelle Staten on 3/25/24.
//

import SwiftUI

struct PaletteList: View {
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        List(store.palettes) { palette in
            Text(palette.name)
        }
    }
}

#Preview {
    PaletteList()
}
