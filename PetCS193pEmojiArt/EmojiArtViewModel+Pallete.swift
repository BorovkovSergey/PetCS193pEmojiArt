//
//  EmojiArtViewModel+Pallete.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 31.05.2021.
//

import Foundation

extension EmojiArtVM {
    private static let PalettesKey = "EmojiArtVM.PalettesKey"
    
    private(set) var PaletteNames: [String:String] {
        get{
            UserDefaults.standard.object(forKey: EmojiArtVM.PalettesKey) as? [String:String] ?? [
                    "πππππ₯°ππππ₯³π‘π€―π₯Άπ€₯π΄ππΏπ·π€§π€‘":"Faces",
                    "πππ₯ππ₯¨π₯ππππ°πΏβοΈ":"Food",
                    "πΆπΌπ΅ππππ¦ππ·ππ¦πͺπ¦π¦¨":"Animals",
                    "β½οΈπβΎοΈπΎππβ³οΈπ₯β·π΄ββοΈπ³πΌπ­πͺ":"Activities"
            ]
        }
        set{
            UserDefaults.standard.set(newValue, forKey: EmojiArtVM.PalettesKey)
            objectWillChange.send()
        }
    }
    
    var sortedPalettes: [String] {
        PaletteNames.keys.sorted(by: { PaletteNames[$0]! < PaletteNames[$1]! })
    }
    
    var defaultPalette: String {
        sortedPalettes.first ?? "β οΈ"
    }
    
    func RenamePalette( _ Palette: String, to name: String ) {
        PaletteNames[Palette] = name
    }
    
    func AddPalette( _ Palette: String, named name: String ) {
        PaletteNames[name] = Palette
    }
    
    func RemovePalette( _ Palette: String, named name: String ) {
        PaletteNames[name] = Palette
    }
    
    @discardableResult
    func AddEmoji(_ emoji: String, toPalette palette: String) -> String {
        ChangePalette(palette, to: (emoji + palette).uniqued())
    }
    
    @discardableResult
    func RemoveEmoji(_ emojisToRemove: String, fromPalette palette: String) -> String {
        ChangePalette(palette, to: palette.filter { !emojisToRemove.contains($0) })
    }
    
    private func ChangePalette( _ Palette: String, to newPalette: String) -> String {
        let name = PaletteNames[Palette] ?? ""
        PaletteNames[Palette] = nil
        PaletteNames[newPalette] = name
        return newPalette
    }
    
    func Palette(after otherPalette: String) -> String {
        Palette(offsetBy: +1, from: otherPalette)
    }
    
    func Palette(before otherPalette: String) -> String {
        Palette(offsetBy: -1, from: otherPalette)
    }
    
    private func Palette(offsetBy offset: Int, from otherPalette: String) -> String {
        if let currentIndex = MostLikelyIndex(of: otherPalette) {
            let newIndex = (currentIndex + (offset >= 0 ? offset : sortedPalettes.count - abs(offset) % sortedPalettes.count)) % sortedPalettes.count
            return sortedPalettes[newIndex]
        } else {
            return defaultPalette
        }
    }
    
    // this is a trick to make the code in the demo a little bit simpler
    // in the real world, we'd want palettes to be Identifiable
    // here we're simply guessing at that π
    private func MostLikelyIndex(of palette: String) -> Int? {
        let paletteSet = Set(palette)
        var best: (index: Int, score: Int)?
        let palettes = sortedPalettes
        for index in palettes.indices {
            let score = paletteSet.intersection(Set(palettes[index])).count
            if score > (best?.score ?? 0) {
                best = (index, score)
            }
        }
        return best?.index
    }
}
