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
    var colorHexCode = ""
    
    init(id: Int) {
        self.id = id
    }
}
