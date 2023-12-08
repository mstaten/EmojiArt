//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/7/23.
//

import SwiftUI

// view model
class PaletteStore: ObservableObject {
    let name: String
    
    @Published var palettes: [Palette] {
        // a little hacky to set the var in didSet, so have to be careful
        // not an infinite loop bc we check to make sure oldValue isn't empty before we use it
        didSet {
            if palettes.isEmpty, !oldValue.isEmpty {
                palettes = oldValue
            }
        }
    }
    
    @Published private var _cursorIndex: Int = 0
    
    var cursorIndex: Int {
        get { boundsCheckedPaletteIndex(_cursorIndex) }
        set { _cursorIndex = boundsCheckedPaletteIndex(newValue) }
    }
    
    init(named name: String) {
        self.name = name
        palettes = Palette.builtIns
        if palettes.isEmpty {
            palettes = [Palette(name: "Warning", emojis: "⚠️")]
        }
    }
    
    private func boundsCheckedPaletteIndex(_ index: Int) -> Int {
        // make sure index is always in the count's space
        var index = index % palettes.count
        if index < 0 {
            index += palettes.count
        }
        return index
    }
    
    func nextPalette() {
        cursorIndex += 1
    }
    
    func deleteCurrentPalette() {
        palettes.remove(at: cursorIndex)
    }

    // MARK: - Adding Palettes
    
    // these functions are the recommended way to add Palettes to the PaletteStore since they
    // try to avoid duplication of Identifiable-y identical Palettes by first removing / replacing
    // any Palette with the same id that is already in Palettes.
    // It does not "remedy" existing duplication; it just doesn't "cause" / allow new duplication
    
    func insert(_ palette: Palette, at insertionIndex: Int? = nil) { // "at" default is cursorIndex
        let insertionIndex = boundsCheckedPaletteIndex(insertionIndex ?? cursorIndex)
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            palettes.move(fromOffsets: IndexSet([index]), toOffset: insertionIndex)
            palettes.replaceSubrange(insertionIndex...insertionIndex, with: [palette])
        } else {
            palettes.insert(palette, at: insertionIndex)
        }
    }
    
    func insert(name: String, emojis: String, at index: Int? = nil) {
        insert(Palette(name: name, emojis: emojis), at: index)
    }
    
    func append(_ palette: Palette) { // at end of palettes
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            if palettes.count == 1 {
                palettes = [palette]
            } else {
                palettes.remove(at: index)
            }
        }
    }
}
