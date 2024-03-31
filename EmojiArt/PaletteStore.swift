//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/7/23.
//

import SwiftUI

extension UserDefaults {
    func palettes(forKey key: String) -> [Palette] {
        if let jsonData = data(forKey: key),
           let decodedPalettes = try? JSONDecoder().decode([Palette].self, from: jsonData) {
            return decodedPalettes
        } else {
            return []
        }
    }
    func set(_ palettes: [Palette], forKey key: String) {
        let data = try? JSONEncoder().encode(palettes)
        set(data, forKey: key)
    }
}

// view model
class PaletteStore: ObservableObject, Identifiable, Hashable {
    let name: String
    
    // define more specific user defaults key, to prevent storing a key with a generic name like "Main"
    private var userDefaultsKey: String { "PaletteStore:" + name }
    
    // because the palette stores are stored in user defaults using the store names, we want the name
    // to be unique, and that'll be its identifier
    var id: String { name }
     
    var palettes: [Palette] {
        get {
            UserDefaults.standard.palettes(forKey: userDefaultsKey)
        }
        set {
            if !newValue.isEmpty {
                UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
                objectWillChange.send()
            }
        }
    }
    
    @Published private var _cursorIndex: Int = 0
    
    // index of the palette that's currently showing
    var cursorIndex: Int {
        get { boundsCheckedPaletteIndex(_cursorIndex) }
        set { _cursorIndex = boundsCheckedPaletteIndex(newValue) }
    }
    
    // initialize the store with built-in palettes or a default warning palette
    // the palettes var should never be truly empty
    init(named name: String) {
        self.name = name
        if palettes.isEmpty {
            palettes = Palette.builtIns
            if palettes.isEmpty {
                palettes = [Palette(name: "Warning", emojis: "⚠️")]
            }
        }
    }
    
    static func == (lhs: PaletteStore, rhs: PaletteStore) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
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
