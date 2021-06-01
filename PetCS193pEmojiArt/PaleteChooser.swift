//
//  PalleteChooser.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 31.05.2021.
//

import SwiftUI

struct PaletteChooser: View {
    
    @ObservedObject var document: EmojiArtVM
    @Binding var chosenPalette: String
    @State var showPaletteEditor: Bool = false
    var body: some View {
        HStack{
            Stepper(
                onIncrement: {
                    self.chosenPalette = self.document.Palette(after: self.chosenPalette)
                },
                onDecrement: {
                    self.chosenPalette = self.document.Palette(before: self.chosenPalette)
                },
                label: {
                    Text(self.document.PaletteNames[self.chosenPalette] ?? "")
                })
            Image(systemName: "keyboard").imageScale(.large)
                .sheet(isPresented: $showPaletteEditor){
                    PaletteEditor(chosenPalette: self.$chosenPalette, isShowing: $showPaletteEditor)
                        .environmentObject(self.document)
                }
                .onTapGesture {
                    self.showPaletteEditor = true
                }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}


struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtVM
    @Binding var chosenPalette: String
    @Binding var isShowing: Bool
    @State var paletteName: String = ""
    @State var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0)
        {
            ZStack{
                Text("Palette Editor").font(.headline).padding()
                HStack{
                    Spacer()
                    Button(action: {
                        self.isShowing = false
                    }, label: { Text("Done")}).padding()
                }
            }
            Divider()
            Form {
                Section{
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            self.document.RenamePalette(self.chosenPalette, to: self.paletteName)
                        }
                    })
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            self.chosenPalette = self.document.AddEmoji(self.emojisToAdd, toPalette: self.chosenPalette)
                            self.emojisToAdd = ""
                        }
                    })
                }
                Section(header: Text("Remove Emoji")) {
                    Grid(chosenPalette.map{ String($0) }, id: \.self) { emoji in
                        Text(emoji).font(Font.system(size: self.fontSize))
                            .onTapGesture{
                                self.chosenPalette = self.document.RemoveEmoji(emoji, fromPalette: self.chosenPalette)
                        }
                    }
                    .frame(height: self.height)
                }
            }
        }
        .onAppear{ self.paletteName = self.document.PaletteNames[self.chosenPalette] ?? "" }
    }
    
    var height: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6 * 70 + 70)
    }
    let fontSize: CGFloat = 40
}
