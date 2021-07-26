//
//  MainTabView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var quickActions: QuickActionService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedIndex = 0
    
    let items: [BottomBarItem] = [
        BottomBarItem(icon: "house.fill", title: "Home", color: .purple),
        BottomBarItem(icon: "list.bullet", title: "Memories", color: .orange),
        BottomBarItem(icon: "person.fill", title: "Profile", color: .blue)
    ]
    
    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var memoriesViewModel = MemoriesViewModel()
    @StateObject var profileViewModel = ProfileViewModel()
    
    fileprivate func handleQuickAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let action = quickActions.action {
                switch action {
                case .home:
                    quickActions.action = nil
                    selectedIndex = 0
                case .memories:
                    quickActions.action = nil
                    selectedIndex = 1
                case .profile:
                    quickActions.action = nil
                    selectedIndex = 2
                default:
                    break
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            if horizontalSizeClass == .compact {
                VStack {
                    if selectedIndex == 0 || quickActions.action == .home {
                        HomeView(viewModel: homeViewModel, memoriesViewModel: memoriesViewModel)
                    } else if selectedIndex == 1 || quickActions.action == .memories {
                        MemoriesView(viewModel: memoriesViewModel)
                    } else if selectedIndex == 2 || quickActions.action == .profile {
                        ProfileView(viewModel: profileViewModel)
                    }
                    BottomBar(selectedIndex: $selectedIndex, items: items)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    handleQuickAction()
                }
                .onAppear(perform: handleQuickAction)
                .onOpenURL { url in
                    if url.absoluteString.hasSuffix("open-most-top") {
                        selectedIndex = 0
                    }
                }
            } else {
                SidebarList(homeViewModel: homeViewModel, memoriesViewModel: memoriesViewModel, profileViewModel: profileViewModel)
                HomeView(viewModel: homeViewModel, memoriesViewModel: memoriesViewModel)
                Text("Select a memory to show its details")
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(QuickActionService())
    }
}
