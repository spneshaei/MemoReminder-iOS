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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
