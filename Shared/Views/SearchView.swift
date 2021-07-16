//
//  SearchView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/15/21.
//

import SwiftUI
import ActivityIndicatorView

struct SearchView: View {
    @EnvironmentObject var globalData: GlobalData
    
    @StateObject var viewModel = SearchViewModel()
    
    @State var showActivityIndicatorView = false
    
    fileprivate func reloadData() async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.loadUsers(globalData: globalData)
            main { showActivityIndicatorView = false }
        } catch {
            main {
                viewModel.showingLoadingUsersErrorAlert = true
                showActivityIndicatorView = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            List(viewModel.filteredUsers) { user in
                SearchUserCell(user: user, searchViewModel: viewModel)
            }
            .searchable(text: $viewModel.searchPredicate)
            .navigationTitle(Text("Search all users"))
            .alert("Error in loading users", isPresented: $viewModel.showingLoadingUsersErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Error in following. Please try again", isPresented: $viewModel.followingErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Your follow request has been sent; when accepted, the user will be displayed as \"Following\" in this list.", isPresented: $viewModel.shouldShowFollowedAlert) {
                Button("OK", role: .cancel) { }
            }
            .task {
                await reloadData()
            }
            .refreshable {
                await reloadData()
            }
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(GlobalData.sample)
    }
}
