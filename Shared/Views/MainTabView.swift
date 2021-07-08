//
//  MainTabView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var homeViewModel = HomeViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label("Memories", systemImage: "list.bullet")
                }
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
