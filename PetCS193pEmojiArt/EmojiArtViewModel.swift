//
//  EmojiArtViewModel.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 20.05.2021.
//

import SwiftUI

class EmojiArtVM: ObservableObject {
    static let emojis: String = "🐶 🐱 🐭 🐹 🐰 🐻 🧸 🐼 🐨 🐯 🦁 🐮 🐷 🐽 🐸 🐵 🙈 🙉 🙊 🐒 🦍 🦧 🐔 🐧 🐦 🐤 🐣 🐥 🐺 🦊 🦝 🐗 🐴 🦓 🦒 "
    
    @Published private var emojiArt = EmojiArt()
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    func AddEmoji(_ emoji: String, at location: CGPoint, with size: CGFloat){
        emojiArt.AddEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func MoveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        
    }
    
    func SetBackgroundURL(_ url: URL){
        
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))}
}
