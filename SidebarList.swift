//
//  SidebarList.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/21/21.
//

import SwiftUI

struct SidebarList: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var memoriesViewModel: MemoriesViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @State private var isHomeViewNavigationLinkActive = true
    @State private var isMemoriesViewNavigationLinkActive = false
    @State private var isProfileViewNavigationLinkActive = false
    
    var body: some View {
        List {
            NavigationLink(destination: HomeView(viewModel: homeViewModel, memoriesViewModel: memoriesViewModel), isActive: $isHomeViewNavigationLinkActive) {
                Button(action: {
                    isHomeViewNavigationLinkActive = true
                    isMemoriesViewNavigationLinkActive = false
                    isProfileViewNavigationLinkActive = false
                }) {
                    Label("Home", systemImage: "house.fill")
                }
            }
            NavigationLink(destination: MemoriesView(viewModel: memoriesViewModel), isActive: $isMemoriesViewNavigationLinkActive) {
                Button(action: {
                    isHomeViewNavigationLinkActive = false
                    isMemoriesViewNavigationLinkActive = true
                    isProfileViewNavigationLinkActive = false
                }) {
                    Label("Memories", systemImage: "list.bullet")
                }
            }
            NavigationLink(destination: ProfileView(viewModel: profileViewModel), isActive: $isProfileViewNavigationLinkActive) {
                Button(action: {
                    isHomeViewNavigationLinkActive = false
                    isMemoriesViewNavigationLinkActive = false
                    isProfileViewNavigationLinkActive = true
                }) {
                    Label("Profile", systemImage: "person.fill")
                }
            }
        }
        .listStyle(.sidebar)
        .navigationBarTitle("MemoReminder")
    }
}

struct SidebarList_Previews: PreviewProvider {
    static var previews: some View {
        SidebarList(homeViewModel: .sample, memoriesViewModel: .sample, profileViewModel: .sample)
    }
}
