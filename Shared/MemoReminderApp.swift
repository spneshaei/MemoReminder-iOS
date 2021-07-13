//
//  MemoReminderApp.swift
//  Shared
//
//  Created by Seyyed Parsa Neshaei on 7/7/21.
//

import SwiftUI

@main
struct MemoReminderApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        Rester.server = "http://memoreminder.ir/api/v1"
    }

    var body: some Scene {
        WindowGroup {
            SignUpView()
//            MainTabView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
