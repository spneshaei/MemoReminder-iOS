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
        Webber.server = "" // TODO: Server URL
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
