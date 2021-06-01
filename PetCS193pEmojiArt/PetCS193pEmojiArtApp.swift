//
//  PetCS193pEmojiArtApp.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 20.05.2021.
//

import SwiftUI

@main
struct PetCS193pEmojiArtApp: App {
    var body: some Scene {
        WindowGroup {
            EmojiArtView(document: EmojiArtVM())
        }
    }
}
