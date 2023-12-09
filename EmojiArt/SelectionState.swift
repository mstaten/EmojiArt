//
//  SelectionState.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/8/23.
//

import SwiftUI

struct SelectionState: ViewModifier {
    let isSelected: Bool
    
    init(_ isSelected: Bool = false) {
        self.isSelected = isSelected
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(color: .yellow.opacity(isSelected ? 1 : 0), radius: isSelected ? 10 : 0 )
    }
}

extension View {
    func selected(_ isSelected: Bool) -> some View {
        return self.modifier(SelectionState(isSelected))
    }
}
