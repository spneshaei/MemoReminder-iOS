//
//  MainTabView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var memoriesViewModel = MemoriesViewModel()
    @StateObject var profileViewModel = ProfileViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            MemoriesView(viewModel: memoriesViewModel)
                .tabItem {
                    Label("Memories", systemImage: "list.bullet")
                }
            ProfileView(viewModel: profileViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
