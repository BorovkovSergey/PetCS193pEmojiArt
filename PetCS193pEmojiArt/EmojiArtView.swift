//
//  EmojiArtView.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 20.05.2021.
//

import SwiftUI


struct EmojiArtView: View {
    
    @ObservedObject var emojiArt = EmojiArtVM()
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScaleEmoji: CGFloat = 1.0
    @GestureState private var gesturePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffsetEmoji: CGSize = .zero
    @State private var chosenPalette: String = ""
    private var zoomScale: CGFloat{
        emojiArt.steadyStateZoomScale * gestureZoomScale
    }

    private var panOffset: CGSize{
        ( emojiArt.steadyStatePanOffset + gesturePanOffset ) *  zoomScale
    }

    private var isLoading: Bool {
        emojiArt.backGroundUrl != nil && emojiArt.backgroundImage == nil
    }
    
    init(document: EmojiArtVM)
    {
        self.emojiArt = document
        _chosenPalette = State(wrappedValue: self.emojiArt.defaultPalette)
    }
    var body: some View {
        ScrollView(.horizontal){
            HStack{
                PaletteChooser(document: emojiArt, chosenPalette: self.$chosenPalette)
                ForEach(self.chosenPalette.map{ String($0) }, id: \.self) { emoji in
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
            .onReceive( emojiArt.$backgroundImage ){ image in self.ZoomToFit(image, in: geometry.size)}
            .onDrop(of: ["public.image", "public.text"], isTargeted: nil){ providers, location in
                var location = geometry.convert(location, from: .global)
                location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                return self.Drop(providers: providers, at: location)
                }
            .navigationBarItems(leading: self.pickImage, trailing: Button(action: {
                if let url = UIPasteboard.general.url, url != self.emojiArt.backGroundUrl {
                    confirmBackgroundPaste = true
                } else {
                    self.explainBackgroundPaste = true
                }
            }, label: {
                Image(systemName: "doc.on.clipboard").imageScale(.large )
                    .alert(isPresented: self.$explainBackgroundPaste){
                        return Alert(
                            title: Text("Paste Background"),
                            message: Text("Failed"),
                            dismissButton: .default(Text("OK")))
                    }
                
            } ))
        }
        .alert(isPresented: self.$confirmBackgroundPaste)
        {
            return Alert(title: Text("Paste Background"),
                         message: Text("Insert image from: \(UIPasteboard.general.url?.absoluteString ?? "nothing") ?"),
                         primaryButton: .default(Text("OK")) {
                            self.emojiArt.backGroundUrl = UIPasteboard.general.url
                         },
                         secondaryButton: .cancel())
        }
        .zIndex(-1)
    }

    @State private var showImagePicker = false
    @State private var imagePickerSourceType = UIImagePickerController.SourceType.photoLibrary
    private var pickImage: some View {
        HStack{
            Image(systemName: "photo").imageScale(.large).foregroundColor(.accentColor).onTapGesture {
                self.imagePickerSourceType = .photoLibrary
                self.showImagePicker = true
            }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Image(systemName: "camer").imageScale(.large).foregroundColor(.accentColor).onTapGesture {
                    self.imagePickerSourceType = .camera
                    self.showImagePicker = true
                }
            }
        }
        .sheet(isPresented: $showImagePicker){
            ImagePicker(sourceType: self.imagePickerSourceType){ image in
                if image != nil {
                    DispatchQueue.main.async {
                        self.emojiArt.backGroundUrl = image!.storeInFilesystem()
                    }
                }
                self.showImagePicker = false
            }
        }
    }
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false
    
    private func ZoomToFit(_ image: UIImage?, in size: CGSize){
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.height / image.size.height
            let vZoom = size.width / image.size.width
            self.emojiArt.steadyStatePanOffset = .zero
            self.emojiArt.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }

    private func ZoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded{ finalGestureScale in
                self.emojiArt.steadyStateZoomScale *= finalGestureScale
            }
    }

    private func PanGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset){ latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
            }
            .onEnded{ finalGestureValue in
                self.emojiArt.steadyStatePanOffset = self.emojiArt.steadyStatePanOffset + finalGestureValue.translation / self.zoomScale
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
                emojiArt.steadyStateZoomScale = 1.0
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
