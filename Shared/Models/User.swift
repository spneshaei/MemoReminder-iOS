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
    var profilePictureURL = ""
    var numberOfMemories = 0
    var numberOfLikes = 0
    var numberOfComments = 0
    
    init(id: String) {
        self.id = id
    }
    
    convenience init() {
        self.init(id: UUID().uuidString)
    }
    
    static var sample: User {
        let user = User()
        user.username = "seyyedparsa"
        user.name = "Seyed Parsa Neshaei Neshaei NeshaeiNeshaei Neshaei"
        user.email = "spn@spn.spn"
        user.birthday = "1943/23/12"
        user.phoneNumber = "12345678911"
        user.profilePictureURL = "" // adjust this!
        user.numberOfMemories = 12
        user.numberOfLikes = 125
        user.numberOfComments = 32
        return user
    }
}
