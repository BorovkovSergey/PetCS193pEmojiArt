//
//  EmojiArtViewModel.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 20.05.2021.
//

import SwiftUI

class EmojiArtVM: ObservableObject {
    static let emojis: String = "🐶 🐱 🐭 🐹 🐰 🐻 🧸 🐼 🐨 🐯 🦁 🐮 🐷 🐽 🐸 🐵 🙈 🙉 🙊 🐒 🦍 🦧 🐔 🐧 🐦 🐤 🐣 🐥 🐺 🦊 🦝 🐗 🐴 🦓 🦒 "
    
    private var emojiArt = EmojiArt() {
        willSet{
            objectWillChange.send()
        }
        didSet{
            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtVM.untitled)
        }
    }
    private static let untitled = "EmojiArtVM.untitled"
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtVM.untitled)) ?? EmojiArt()
        FetchBackgroundImageData()
    }
    @Published var backgroundImage: UIImage?
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    func AddEmoji(_ emoji: String, at location: CGPoint, with size: CGFloat){
        emojiArt.AddEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func MoveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let selectedIndex = emojiArt.emojis.FirstIndex(matching: emoji) {
            emojiArt.emojis[selectedIndex].x = Int(offset.width)
            emojiArt.emojis[selectedIndex].y = Int(offset.height)
        }
    }
    
    func ScaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let selectedIndex = emojiArt.emojis.FirstIndex(matching: emoji) {
            emojiArt.emojis[selectedIndex].size = Int((CGFloat(emojiArt.emojis[selectedIndex].size) * scale).rounded(.toNearestOrEven))
        }
    }
    func SetBackgroundURL(_ url: URL){
        emojiArt.backgroundURL = url.imageURL
        FetchBackgroundImageData()
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
