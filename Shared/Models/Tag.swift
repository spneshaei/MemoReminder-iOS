//
//  Tag.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import Foundation

class Tag: Identifiable, Codable {
    var id: String
    
    var name = ""
    var colorHexCode = ""
    
    init(id: String) {
        self.id = id
    }
    
    convenience init() {
        self.init(id: UUID().uuidString)
    }
}
