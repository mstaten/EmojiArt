//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Michelle Staten on 3/24/24.
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette: Palette
    @State var emojisToAdd: String = ""
    @FocusState private var focused: Focused?
    
    private let emojiFont: Font = .system(size: 40)
    
    enum Focused {
        case name
        case addEmojis
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $palette.name)
                    .focused($focused, equals: .name)
            } header: {
                Text("Name")
            }
            Section {
                TextField("Add Emojis Here", text: $emojisToAdd)
                    .focused($focused, equals: .addEmojis)
                    .font(emojiFont)
                    .onChange(of: emojisToAdd) { emojisToAdd in
                        palette.emojis = (emojisToAdd + palette.emojis)
                            .filter{ $0.isEmoji }
                            .uniqued
                    }
                removeEmojis
            } header: {
                Text("Emojis")
            }
        }
        .onAppear {
            if palette.name.isEmpty {
                focused = .name
            } else {
                focused = .addEmojis
            }
        }
        .frame(minWidth: 300, minHeight: 350)
    }
    
    private var removeEmojis: some View {
        VStack(alignment: .trailing) {
            Text("Tap to Remove Emojis").font(.caption).foregroundStyle(.gray)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.remove(emoji.first!)
                                emojisToAdd.remove(emoji.first!)
                            }
                        }
                }
            }
        }
        .font(emojiFont)
    }
}

#Preview {
    struct BindingViewExamplePreviewContainer: View {
        @State private var palette: Palette = PaletteStore(named: "Preview").palettes.first!
        
        var body: some View {
            PaletteEditor(palette: $palette)
        }
    }
    
    return BindingViewExamplePreviewContainer()
}
