//
//  User.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import Foundation

class User: Identifiable, Codable {
    var id: String
    
    var username = ""
    var name = ""
    var email = ""
    var birthday = ""
    var phoneNumber = ""
    var token = ""
    
    init(id: String) {
        self.id = id
    }
    
    convenience init() {
        self.init(id: UUID().uuidString)
    }
}
