//
//  AnimatableFont.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 22.05.2021.
//

import SwiftUI

struct AnimatableFontModifier: AnimatableModifier {
    var size: CGFloat
    var weight: Font.Weight = .regular
    var design: Font.Design = .default
    
    func body(content: Content) -> some View {
        content.font(Font.system(size: size, weight: weight, design: design))
    }
    
    var animatableData: CGFloat{
        get{ size }
        set{ size = newValue }
    }
}

extension View {
    func font(animatbleWtihSize size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View{
        self.modifier(AnimatableFontModifier(size: size, weight: weight, design: design))
    }
}
