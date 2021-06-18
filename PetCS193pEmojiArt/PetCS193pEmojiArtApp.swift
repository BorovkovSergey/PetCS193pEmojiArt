//
//  PetCS193pEmojiArtApp.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 20.05.2021.
//

import SwiftUI

@main
struct PetCS193pEmojiArtApp: App {
//    private let store = EmojiArtDocumentStore(named: "Emoji Art")
    var body: some Scene {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let store = EmojiArtDocumentStore(directory: url)
        return WindowGroup {
            EmojiArtDocumentChooser().environmentObject(store)
//            EmojiArtView(document: EmojiArtVM())
        }
    }
}
