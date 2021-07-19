//
//  MemoReminderApp.swift
//  Shared
//
//  Created by Seyyed Parsa Neshaei on 7/7/21.
//

import SwiftUI
import UIKit

extension View {
    func erasedToAnyView() -> AnyView {
        AnyView(self)
    }
}

@main
struct MemoReminderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    let persistenceController = PersistenceController.shared
    @StateObject var globalData = GlobalData()
    @StateObject var viewModel = MainAppViewModel()
    
    private let quickActionService = QuickActionService()
    
    init() {
        Rester.server = "http://memoreminder.ir/api/v1"
    }

    var body: some Scene {
        WindowGroup {
            TopView()
                .environmentObject(quickActionService)
                .environmentObject(globalData)
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    viewModel.currentView = globalData.loggedIn ? .mainTabView : .login
                }
        }
        .onChange(of: scenePhase) { scenePhase in
            switch scenePhase {
            case .active:
                guard let shortcutItem = appDelegate.shortcutItem else { return }
                quickActionService.action = QuickAction(rawValue: shortcutItem.type)
            default:
                return
            }
        }
    }
}
