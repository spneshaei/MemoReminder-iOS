//
//  MainTabView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedIndex = 0
    
    let items: [BottomBarItem] = [
        BottomBarItem(icon: "house.fill", title: "Home", color: .purple),
        BottomBarItem(icon: "list.bullet", title: "Memories", color: .orange),
        BottomBarItem(icon: "person.fill", title: "Profile", color: .blue)
    ]
    
    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var memoriesViewModel = MemoriesViewModel()
    @StateObject var profileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack {
            if selectedIndex == 0 {
                HomeView(viewModel: homeViewModel)
            } else if selectedIndex == 1 {
                MemoriesView(viewModel: memoriesViewModel)
            } else if selectedIndex == 2 {
                ProfileView(viewModel: profileViewModel)
            }
            BottomBar(selectedIndex: $selectedIndex, items: items)
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded({ value in
            if value.translation.width < 0 && selectedIndex != 2 {
                withAnimation {
                    selectedIndex += 1
                }
            }
            
            if value.translation.width > 0 && selectedIndex != 0 {
                withAnimation {
                    selectedIndex -= 1
                }
            }
        }))
        //        TabView {
        //            HomeView(viewModel: homeViewModel)
        //                .tabItem {
        //                    Label("Home", systemImage: "house")
        //                }
        //            MemoriesView(viewModel: memoriesViewModel)
        //                .tabItem {
        //                    Label("Memories", systemImage: "list.bullet")
        //                }
        //            ProfileView(viewModel: profileViewModel)
        //                .tabItem {
        //                    Label("Profile", systemImage: "person")
        //                }
        //        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
