//
//  EmojiArtDocumentStore.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 5/6/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI
import Combine

class EmojiArtDocumentStore: ObservableObject
{
    let name: String
    
    func name(for document: EmojiArtVM) -> String {
        if documentNames[document] == nil {
            documentNames[document] = "Untitled"
        }
        return documentNames[document]!
    }
    
    func setName(_ name: String, for document: EmojiArtVM) {
        documentNames[document] = name
    }
    
    var documents: [EmojiArtVM] {
        documentNames.keys.sorted { documentNames[$0]! < documentNames[$1]! }
    }
    
    func addDocument(named name: String = "Untitled") {
        documentNames[EmojiArtVM()] = name
    }

    func removeDocument(_ document: EmojiArtVM) {
        documentNames[document] = nil
    }
    
    @Published private var documentNames = [EmojiArtVM:String]()
    
    private var autosave: AnyCancellable?
    
    init(named name: String = "Emoji Art") {
        self.name = name
        let defaultsKey = "EmojiArtVMStore.\(name)"
        documentNames = Dictionary(fromPropertyList: UserDefaults.standard.object(forKey: defaultsKey))
        autosave = $documentNames.sink { names in
            UserDefaults.standard.set(names.asPropertyList, forKey: defaultsKey)
        }
    }
}

extension Dictionary where Key == EmojiArtVM, Value == String {
    var asPropertyList: [String:String] {
        var uuidToName = [String:String]()
        for (key, value) in self {
            uuidToName[key.id.uuidString] = value
        }
        return uuidToName
    }
    
    init(fromPropertyList plist: Any?) {
        self.init()
        let uuidToName = plist as? [String:String] ?? [:]
        for uuid in uuidToName.keys {
            self[EmojiArtVM(id: UUID(uuidString: uuid))] = uuidToName[uuid]
        }
    }
}
