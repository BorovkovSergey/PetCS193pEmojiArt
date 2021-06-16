//
//  EmojiArtViewModel.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 20.05.2021.
//

import SwiftUI
import Combine

class EmojiArtVM: ObservableObject, Hashable, Identifiable  {
    static func == (lhs: EmojiArtVM, rhs: EmojiArtVM) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static let emojis: String = "🐶 🐱 🐭 🐹 🐰 🐻 🧸 🐼 🐨 🐯 🦁 🐮 🐷 🐽 🐸 🐵 🙈 🙉 🙊 🐒 🦍 🦧 🐔 🐧 🐦 🐤 🐣 🐥 🐺 🦊 🦝 🐗 🐴 🦓 🦒 "
    
    @Published var emojiArt = EmojiArt()
    @Published var steadyStatePanOffset: CGSize = .zero
    @Published  var steadyStateZoomScale: CGFloat = 1.0
    
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
    init(id: UUID? = nil ) {
        self.id = id ?? UUID()
        let defaultKey = "EmojiArtVM.\(self.id.uuidString)"
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultKey)) ?? EmojiArt()
        autosaveCancellable = $emojiArt.sink{ emojiArt in
                UserDefaults.standard.set(emojiArt.json, forKey: defaultKey)
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
    
    private var fetchImageCancellable: AnyCancellable?
    private func FetchBackgroundImageData(){
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            fetchImageCancellable?.cancel()
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map{ data, urlResponse in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \.backgroundImage, on: self)
        }
        
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))}
}
