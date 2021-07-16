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
    
    var id: Int
    
    var creatorUserID = 0
    var creatorUsername = ""
    var creatorFirstName = ""
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
    var hasCurrentUserLiked = false
    var comments: [Comment] = []
    
    init(id: Int) {
        self.id = id
    }
    
    static var sample: Memory {
        let memory = Memory(id: 1)
        memory.title = "A great memory"
        memory.creatorUserID = 0
        memory.creatorUsername = "seyyedparsa"
        memory.creatorFirstName = "Seyed Parsa"
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
        memory.hasCurrentUserLiked = false
        memory.comments = [Comment.sample]
        return memory
    }
    
    static func memoryFromResultJSON(_ result: JSON, currentUserID: Int) -> Memory {
        let memory = Memory(id: result["id"].intValue)
        memory.creatorUserID = result["creator_user"]["id"].intValue
        memory.creatorUsername = result["creator_user"]["username"].stringValue
        memory.creatorFirstName = result["creator_user"]["first_name"].stringValue // TODO: Last name!
        memory.title = result["title"].stringValue
        memory.contents = result["text"].stringValue
        let likes = result["likes"].arrayValue
        memory.numberOfLikes = likes.count
        memory.hasCurrentUserLiked = likes.contains { like in like["memo_user"]["id"].intValue == currentUserID }
        memory.comments = result["comments"].arrayValue.map { commentJSON in
            let comment = Comment(id: commentJSON["id"].intValue)
            let commentUser = commentJSON["memo_user"]
            comment.senderUsername = commentUser["username"].stringValue
            comment.senderFirstName = commentUser["first_name"].stringValue
            comment.senderLastName = commentUser["last_name"].stringValue
            comment.contents = commentJSON["text"].stringValue
            let commentLikes = commentJSON["likes"].arrayValue
            comment.numberOfLikes = commentLikes.count
            comment.hasCurrentUserLiked = commentLikes.contains { like in like["memo_user"]["id"].intValue == currentUserID }
            return comment
        }
        return memory
    }
}
