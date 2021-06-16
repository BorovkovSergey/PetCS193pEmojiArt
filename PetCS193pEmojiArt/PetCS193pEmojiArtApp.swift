//
//  PetCS193pEmojiArtApp.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 20.05.2021.
//

import SwiftUI

@main
struct PetCS193pEmojiArtApp: App {
    private let store = EmojiArtDocumentStore(named: "Emoji Art")
    var body: some Scene {
        store.addDocument(named: "test")
        store.addDocument(named: "test2")
        return WindowGroup {
            EmojiArtDocumentChooser().environmentObject(store)
//            EmojiArtView(document: EmojiArtVM())
        }
    }
}
