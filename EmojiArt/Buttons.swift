//
//  Buttons.swift
//  EmojiArt
//
//  Created by Michelle Staten on 12/8/23.
//

import SwiftUI

struct AnimatedActionButton: View {
    var title: String?
    var systemImage: String?
    var role: ButtonRole?
    let disabled: Bool
    let action: () -> Void
    
    init(
        _ title: String? = nil,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.disabled = disabled
        self.action = action
    }
    
    var body: some View {
        Button(role: role) {
            withAnimation {
                action()
            }
        } label: {
            HStack {
                if let title, let systemImage {
                    Label(title, systemImage: systemImage)
                } else if let title {
                    Text(title)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
            }
        }
        .disabled(disabled)
    }
}

struct AnimatedActionButton_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedActionButton("Long press here") {}
            .contextMenu {
                AnimatedActionButton("Add") {}
                AnimatedActionButton("Edit", systemImage: "pencil") {}
                AnimatedActionButton("Delete", systemImage: "minus.circle", role: .destructive) {}
                AnimatedActionButton("Click me if you can", disabled: true) {}
                AnimatedActionButton("Cancel", systemImage: "xmark.circle", role: .cancel) {}
            }
    }
}
