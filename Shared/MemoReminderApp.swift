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
    @StateObject var viewModel = MainAppViewModel()
    
    init() {
        Rester.server = "http://memoreminder.ir/api/v1"
    }

    var body: some Scene {
        WindowGroup {
            switch viewModel.currentView {
            case .login:
                LoginView(viewModel: viewModel)
                    .erasedToAnyView()
            case .signUp:
                SignUpView(viewModel: viewModel)
                    .erasedToAnyView()
            case .mainTabView:
                MainTabView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .erasedToAnyView()
            }
        }
    }
}
