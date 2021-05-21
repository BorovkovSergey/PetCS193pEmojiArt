//
//  EmojiArtView.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 20.05.2021.
//

import SwiftUI

struct EmojiArtView: View {
    
    @ObservedObject var emojiArt = EmojiArtVM()
    var body: some View {
        ScrollView(.horizontal){
            HStack{
                ForEach(EmojiArtVM.emojis.map{ String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .font(SwiftUI.Font.system(size: self.defaultEmojiSize))
                        .onDrag { return NSItemProvider(object: emoji as NSString) }
                }
            }
        }
        .padding(.horizontal)
        GeometryReader{ geometry in
            Color.yellow.overlay(
                Group{
                    if self.emojiArt.backgroundImage != nil {
                        Image(uiImage: self.emojiArt.backgroundImage!)
                    }
                })
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil){ providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    return self.Drop(providers: providers, at: location)
                }
            ForEach(self.emojiArt.emojis){ emoji in
                Text(emoji.content)
                    .font(self.Font(for: emoji))
                    .position(self.Position( for: emoji, in: geometry.size))
            }
        }
    }
    
    private func Font( for emoji: EmojiArt.Emoji )-> Font {
        SwiftUI.Font.system(size: emoji.fontSize)
    }
    
    private func Position( for emoji: EmojiArt.Emoji, in size: CGSize ) -> CGPoint{
        CGPoint(x: emoji.location.x + size.width/2, y: emoji.location.y + size.height/2)
    }
    func Drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.emojiArt.SetBackgroundURL(url)
        }
        if !found {
            found = providers.loadFirstObject(ofType: String.self) { string in
                self.emojiArt.AddEmoji(string, at: location, with: self.defaultEmojiSize)
            }
        }
        return found
    }

    private let defaultEmojiSize: CGFloat = 40
}
