//
//  MemoReminderApp.swift
//  Shared
//
//  Created by Seyyed Parsa Neshaei on 7/7/21.
//

import SwiftUI

extension View {
    func erasedToAnyView() -> AnyView {
        AnyView(self)
    }
}

@main
struct MemoReminderApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var globalData = GlobalData()
    @StateObject var viewModel = MainAppViewModel()
    
    init() {
        Rester.server = "http://memoreminder.ir/api/v1"
    }

    var body: some Scene {
        WindowGroup {
            TopView()
                .environmentObject(globalData)
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    viewModel.currentView = globalData.loggedIn ? .mainTabView : .login
                }
        }
    }
}
