//
//  EmojiArt.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 20.05.2021.
//

import Foundation

struct EmojiArt {
    var emojis = [Emoji]()
    var uniqueEmojiID = 0
    
    struct Emoji: Identifiable {
        let content: String
        var x: Int
        var y: Int
        var size: Int
        let id: Int
        
        fileprivate init(_ content: String, _ x: Int, _ y: Int, _ size: Int, _ id: Int){
            self.content = content
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    mutating func AddEmoji(_ content: String, x: Int, y: Int, size: Int ) {
        emojis.append(Emoji( content, x, y, size, uniqueEmojiID))
        uniqueEmojiID += 1
    }
}
