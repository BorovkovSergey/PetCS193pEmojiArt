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
        if let url = directory?.appendingPathComponent(name){
            if documentNames.values.contains(name) {
                return
            }
            removeDocument(document)
            document.url = url
        }
        documentNames[document] = name
    }
    
    var documents: [EmojiArtVM] {
        documentNames.keys.sorted { documentNames[$0]! < documentNames[$1]! }
    }
    
    func addDocument(named name: String = "Untitled") {
        let uniqueName = name.uniqued(withRespectTo: documentNames.values)
        let document: EmojiArtVM
        if let url = directory?.appendingPathComponent(uniqueName){
            document = EmojiArtVM(url: url)
        } else {
            document = EmojiArtVM()
        }
        documentNames[document] = uniqueName
    }

    func removeDocument(_ document: EmojiArtVM) {
        if let name = documentNames[document], let url = directory?.appendingPathComponent(name) {
            try? FileManager.default.removeItem(at: url)
        }
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
    
    private var directory: URL?
    init(directory: URL){
        self.name = directory.lastPathComponent
        self.directory = directory
        do{
            let documents = try FileManager.default.contentsOfDirectory(atPath: directory.path)
            for document in documents {
                let emojiArtDocument = EmojiArtVM(url: directory.appendingPathComponent(document))
                self.documentNames[emojiArtDocument] = document
            }
        } catch {
            print("failed to create store from directory: \(String(describing: self.directory)): \(error.localizedDescription)")
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
