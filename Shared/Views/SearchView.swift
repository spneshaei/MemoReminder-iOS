//
//  SearchView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/15/21.
//

import SwiftUI
import ActivityIndicatorView

struct SearchView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var globalData: GlobalData
    
    @StateObject var viewModel = SearchViewModel()
    @Binding var usersSelected: [User]
    
    @State var showActivityIndicatorView = false

    var shouldSelectUsers = false
    
    init(shouldSelectUsers: Bool = false, usersSelected: Binding<[User]> = .constant([])) {
        self.shouldSelectUsers = shouldSelectUsers
        self._usersSelected = usersSelected
    }
    
    fileprivate func reloadData() async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.loadUsers(globalData: globalData)
            main { showActivityIndicatorView = false }
        } catch {
            main {
                showActivityIndicatorView = false
                viewModel.showingLoadingUsersErrorAlert = true
            }
        }
    }
    
    var body: some View {
        ZStack {
            List(viewModel.filteredUsers) { user in
                SearchUserCell(user: user, searchViewModel: viewModel, shouldSelectUsers: shouldSelectUsers)
                    .opacity(shouldSelectUsers ? (usersSelected.contains(where: { $0.id == user.id }) ? 0.65 : 1) : 1)
                    .onTapGesture {
                        if shouldSelectUsers {
                            if usersSelected.contains(where: { $0.id == user.id }) {
                                viewModel.showingPreviouslyMentionedUserErrorAlert = true
                            } else {
                                usersSelected.append(user)
                                self.mode.wrappedValue.dismiss()
                            }
                        }
                    }
            }
            .listStyle(.plain)
            .searchable(text: $viewModel.searchPredicate)
            .navigationTitle(Text("Search all users"))
            .alert("This user has been previously mentioned", isPresented: $viewModel.showingPreviouslyMentionedUserErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Error in loading users", isPresented: $viewModel.showingLoadingUsersErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Error in following the user. Please try again", isPresented: $viewModel.followingErrorAlert) {
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
