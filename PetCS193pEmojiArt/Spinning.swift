//
//  Spinning.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 31.05.2021.
//

import SwiftUI

struct Spinning: ViewModifier{
    @State var isVisible: Bool = false
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: self.isVisible ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear{ self.isVisible = true }
    }
}

extension View {
    func spinning() -> some View {
        self.modifier(Spinning())
    }
}
