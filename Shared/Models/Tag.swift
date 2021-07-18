//
//  Tag.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import Foundation

class Tag: Identifiable, Codable {
    var id: Int
    
    var name = ""
    var color = ""
    
    init(id: Int) {
        self.id = id
    }
    
    static var sample: Tag {
        let tag = Tag(id: Int.random(in: 1...100))
        tag.name = ["friends", "history", "family", "university", "development course", "fun", "joke", "meme"].randomElement()!
        tag.color = ["ffd800", "00ff00"].randomElement()!
        return tag
    }
}
