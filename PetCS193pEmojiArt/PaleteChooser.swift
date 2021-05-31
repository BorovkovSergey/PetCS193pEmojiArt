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
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}
