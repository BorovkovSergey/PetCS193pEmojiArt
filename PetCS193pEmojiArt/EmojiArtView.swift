//
//  EmojiArtView.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 20.05.2021.
//

import SwiftUI


struct EmojiArtView: View {
    
    @ObservedObject var emojiArt = EmojiArtVM()
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScaleEmoji: CGFloat = 1.0
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffsetEmoji: CGSize = .zero
    
    private var zoomScale: CGFloat{
        steadyStateZoomScale * gestureZoomScale
    }

    private var panOffset: CGSize{
        ( steadyStatePanOffset + gesturePanOffset ) *  zoomScale
    }

    private var isLoading: Bool {
        emojiArt.backGroundUrl != nil && emojiArt.backgroundImage == nil
    }
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
                        .offset(self.panOffset)
                        .gesture(self.DoubleTapZoom(in: geometry.size))
                        .gesture(self.PanGesture())
                        .gesture(self.ZoomGesture())
                    )
                if self.isLoading{
                    Image(systemName: "hourglass").imageScale(.large).spinning()
                } else {
                    ForEach(self.emojiArt.emojis){ emoji in
                        Text(emoji.content)
                            .font(animatbleWtihSize: emoji.fontSize * zoomScale)
                            .position(self.Position( for: emoji, in: geometry.size))
                            .gesture(self.PanGesture(for: emoji))
                            .gesture(self.ZoomGesture(for: emoji))
                    }
                }
            }
            .clipped()
            .edgesIgnoringSafeArea([.horizontal, .bottom])
            .onDrop(of: ["public.image", "public.text"], isTargeted: nil){ providers, location in
                var location = geometry.convert(location, from: .global)
                location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                return self.Drop(providers: providers, at: location)
                }
        }
    }

    private func ZoomToFit(_ image: UIImage?, in size: CGSize){
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.height / image.size.height
            let vZoom = size.width / image.size.width
            self.steadyStatePanOffset = .zero
            self.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }

    private func ZoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded{ finalGestureScale in
                self.steadyStateZoomScale *= finalGestureScale
            }
    }

    private func PanGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset){ latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
            }
            .onEnded{ finalGestureValue in
                self.steadyStatePanOffset = self.steadyStatePanOffset + finalGestureValue.translation / self.zoomScale
            }
    }
    
    static var startLocation: CGPoint? = nil
    private func PanGesture( for emoji: EmojiArt.Emoji) -> some Gesture {
        let id = emojiArt.emojis.FirstIndex(matching: emoji)!
        return DragGesture()
            .updating($gesturePanOffsetEmoji){ latestDragGestureValue, gesturePanOffsetEmoji, transaction in
                if EmojiArtView.startLocation == nil {
                    EmojiArtView.startLocation = emojiArt.emojis[id].location
                }
                emojiArt.MoveEmoji(by: id, by: CGSize(
                                    width: EmojiArtView.startLocation!.x + latestDragGestureValue.translation.width / zoomScale,
                                    height: EmojiArtView.startLocation!.y + latestDragGestureValue.translation.height / zoomScale))
            }
            .onEnded{ _ in EmojiArtView.startLocation = nil }
    }
    
    static var startZoomScale: Int? = nil
    private func ZoomGesture(for emoji: EmojiArt.Emoji) -> some Gesture {
        let id = emojiArt.emojis.FirstIndex(matching: emoji)!
        return MagnificationGesture()
            .updating($gestureZoomScaleEmoji) { latestGestureScale, gestureZoomScale, transaction in
                if EmojiArtView.startZoomScale == nil {
                    EmojiArtView.startZoomScale = emojiArt.emojis[id].size
                }
                emojiArt.ScaleEmoji(by: id, by: latestGestureScale * self.defaultEmojiSize)
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
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }

    func Drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            withAnimation{
                steadyStateZoomScale = 1.0
            }
            self.emojiArt.backGroundUrl = url
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
