//
//  OptionalImage.swift
//  PetCS193pEmojiArt
//
//  Created by Sergey Borovkov on 22.05.2021.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    var body: some View{
        Group{
            if self.uiImage != nil {
                Image(uiImage: self.uiImage!)
            }
        }
    }
}
