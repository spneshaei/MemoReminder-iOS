//
//  Memory.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import Foundation

class Memory: Identifiable, Codable {
    enum PrivacyStatus: String, Codable {
        case publicStatus = "public"
        case privateStatus = "private"
    }
    
    var id: String
    
    var creatorUsername = ""
    var createdDate = ""
    var creatorProfilePictureURL = ""
    var title = ""
    var contents = ""
    var voiceLink = ""
    var imageLink = ""
    var videoLink = ""
    var tagIDs: [String] = []
    var usernamesInvolved: [String] = []
    var privacyStatus: PrivacyStatus = .publicStatus
    var latitude = 0.0
    var longitude = 0.0
    var numberOfLikes = 0
    var commentIDs: [String] = []
    
    init(id: String) {
        self.id = id
    }
    
    convenience init() {
        self.init(id: UUID().uuidString)
    }
    
    // TODO: Adjust this fields!
    static var sample: Memory {
        let memory = Memory()
        memory.title = "A great memory"
        memory.creatorUsername = "seyyedparsa"
        memory.createdDate = "2021 21 21"
        memory.creatorProfilePictureURL = ""
        memory.contents = "This was the best memory ever, ever, ever!!!"
        memory.voiceLink = ""
        memory.imageLink = ""
        memory.videoLink = ""
        memory.tagIDs = []
        memory.usernamesInvolved = ["seyyedparsa"]
        memory.privacyStatus = .publicStatus
        memory.latitude = 10
        memory.longitude = 20
        memory.numberOfLikes = 5
        memory.commentIDs = []
        return memory
    }
}
