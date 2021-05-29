//
//  EmojiArtView.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 20.05.2021.
//

import SwiftUI


struct EmojiArtView: View {
    
    @ObservedObject var emojiArt = EmojiArtVM()
    @State private var zoomScale: CGFloat = 1.0
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
            ZStack{
                Color.white.overlay(
                    OptionalImage(uiImage: self.emojiArt.backgroundImage)
                        .scaleEffect(self.zoomScale)
                        .gesture(self.DoubleTapZoom(in: geometry.size))
                    )
                ForEach(self.emojiArt.emojis){ emoji in
                    Text(emoji.content)
                        .font(animatbleWtihSize: emoji.fontSize * zoomScale)
                        .position(self.Position( for: emoji, in: geometry.size))
                }
            }
            .clipped()
            .edgesIgnoringSafeArea([.horizontal, .bottom])
            .onDrop(of: ["public.image", "public.text"], isTargeted: nil){ providers, location in
                var location = geometry.convert(location, from: .global)
                location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                return self.Drop(providers: providers, at: location)
                }
        }
    }
    
    private func ZoomToFit(_ image: UIImage?, in size: CGSize){
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.height / image.size.height
            let vZoom = size.width / image.size.width
            self.zoomScale = min(hZoom, vZoom)
        }
    }
    
    private func DoubleTapZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded(){
                withAnimation{
                    self.ZoomToFit(self.emojiArt.backgroundImage, in: size)
                }
            }
    }
    
    private func Position( for emoji: EmojiArt.Emoji, in size: CGSize ) -> CGPoint{
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        return location
    }

    func Drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            
                withAnimation{
            zoomScale = 1.0
                }
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
