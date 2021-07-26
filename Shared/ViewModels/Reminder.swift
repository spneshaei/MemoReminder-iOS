//
//  Reminder.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import Foundation

class Reminder: Identifiable, Codable {
    var id: String
    
    var date = Date()
    var text = ""
    
    init(id: String) {
        self.id = id
    }
    
    init() {
        self.id = UUID().uuidString
    }
    
    static var sample: Reminder {
        let reminder = Reminder()
        reminder.date = Date()
        reminder.text = "Add memory"
        return reminder
    }
}
