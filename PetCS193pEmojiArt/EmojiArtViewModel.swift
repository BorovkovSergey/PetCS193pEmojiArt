//
//  EmojiArtViewModel.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 20.05.2021.
//

import SwiftUI
import Combine

class EmojiArtVM: ObservableObject {
    static let emojis: String = "🐶 🐱 🐭 🐹 🐰 🐻 🧸 🐼 🐨 🐯 🦁 🐮 🐷 🐽 🐸 🐵 🙈 🙉 🙊 🐒 🦍 🦧 🐔 🐧 🐦 🐤 🐣 🐥 🐺 🦊 🦝 🐗 🐴 🦓 🦒 "
    
    @Published var emojiArt = EmojiArt()
    
    private static let untitled = "EmojiArtVM.untitled"
    
    var backGroundUrl: URL? {
        get{
            emojiArt.backgroundURL
        }
        set{
            emojiArt.backgroundURL = newValue?.imageURL
            FetchBackgroundImageData()
        }
    }
    
    private var autosaveCancellable: AnyCancellable?
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtVM.untitled)) ?? EmojiArt()
        autosaveCancellable = $emojiArt.sink{ emojiArt in
                UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtVM.untitled)
        }
        FetchBackgroundImageData()
    }

    @Published var backgroundImage: UIImage?
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    func AddEmoji(_ emoji: String, at location: CGPoint, with size: CGFloat){
        emojiArt.AddEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func MoveEmoji(by id: Int, by newPos: CGSize) {
        emojiArt.emojis[id].x = Int(newPos.width)
        emojiArt.emojis[id].y = Int(newPos.height)
    }
    
    func ScaleEmoji(by id: Int, by newSize: CGFloat) {
            emojiArt.emojis[id].size = Int((newSize).rounded(.toNearestOrEven))
    }
    
    private func FetchBackgroundImageData(){
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if url == self.emojiArt.backgroundURL {
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))}
}
