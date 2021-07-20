//
//  NotificationRemindersViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI

class RemindersViewModel: ObservableObject {
    let defaults = UserDefaults(suiteName: "group.com.spneshaei.MemoReminder") ?? .standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    var isSample = false
    
    @Published var reminders: [Reminder] {
        didSet {
            defaults.set(try? encoder.encode(reminders), forKey: "NotificationRemindersViewModel_reminders")
        }
    }
    
    init() {
        if let reminders = try? decoder.decode([Reminder].self, from: defaults.data(forKey: "NotificationRemindersViewModel_reminders") ?? Data()) {
            self.reminders = reminders
        } else {
            self.reminders = []
        }
    }
    
    static var sample: RemindersViewModel {
        let viewModel = RemindersViewModel()
        viewModel.reminders = [.sample]
        return viewModel
    }
}
