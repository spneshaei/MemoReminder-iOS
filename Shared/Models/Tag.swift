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
        let tag = Tag(id: 0)
        tag.name = "Friends"
        tag.color = "ffc800"
        return tag
    }
}
