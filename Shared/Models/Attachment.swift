//
//  Attachment.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/21/21.
//

import Foundation

class Attachment: Identifiable, Codable {
    
    enum AttachmentStatus: String, Codable {
        case notDownloaded = "notDownloaded", downloaded = "downloaded"
    }
    
    var id: String
    var status: AttachmentStatus = .notDownloaded
    var url: String
    unowned var memory: Memory
    
    init(id: String, memory: Memory, url: String) {
        self.id = id
        self.memory = memory
        self.url = url
    }
    
    init(memory: Memory, url: String) {
        self.id = UUID().uuidString
        self.memory = memory
        self.url = url
    }
    
    
}
