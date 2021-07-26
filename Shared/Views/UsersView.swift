//
//  SearchView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/15/21.
//

import SwiftUI
import ActivityIndicatorView

struct UsersView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var globalData: GlobalData
    
    @ObservedObject var viewModel = UsersViewModel()
    @Binding var usersSelected: [User]
    
    @State var showActivityIndicatorView = false
    @State var isNavigationLinkToFilterActive = false
    @State var shouldNavigateToFindContactsPage = false
    
    @StateObject var contactsSuggestionViewModel = ContactsSuggestionsViewModel()

    var shouldSelectUsers = false
    
    init(shouldSelectUsers: Bool = false, usersSelected: Binding<[User]> = .constant([]), viewModel: UsersViewModel = UsersViewModel()) {
        self.shouldSelectUsers = shouldSelectUsers
        self._usersSelected = usersSelected
        self.viewModel = viewModel
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
    
    fileprivate func navigateToFindContactsPage() {
        requestAccess { response in
            if response {
                print("Contacts Acess Granted")
                fetchContacts { result in
                    switch result {
                        case .success(let contacts):
                            // Do your thing here with [CNContacts] array
                            main {
                                contactsSuggestionViewModel.contacts = contacts
                                shouldNavigateToFindContactsPage = true
                            }
                        case .failure(let error):
                            // TODO: Do something with the error...
                            break
                    }
                }
            } else {
                print("Contacts Acess Denied")
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
                                usersSelected.removeAll { user.id == $0.id }
                            } else {
                                usersSelected.append(user)
                                self.mode.wrappedValue.dismiss()
                            }
                        }
                    }
            }
            .listStyle(.plain)
            .searchable(text: $viewModel.searchPredicate)
            .navigationTitle(Text(viewModel.shouldShowPredeterminedUsers ? "Mentioned users" : "Search all users"))
            .alert("Error in loading users", isPresented: $viewModel.showingLoadingUsersErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .task { await reloadData() }
            .refreshable { await reloadData() }
            .navigationBarItems(trailing: NavigationLink(destination: ContactsSuggestionsView(viewModel: contactsSuggestionViewModel, searchViewModel: viewModel), isActive: $shouldNavigateToFindContactsPage) {
                Button(action: { navigateToFindContactsPage() }) {
                    Image(systemName: "wand.and.stars")
                        .accessibility(hint: Text("See contacts suggestions"))
                }
            })
            
            // TODO: Next comment block :(
//            .navigationBarItems(trailing: NavigationLink(destination: UsersFilterView(searchViewModel: viewModel), isActive: $isNavigationLinkToFilterActive) {
//                if !viewModel.shouldShowPredeterminedUsers {
//                    Button(action: {
//                        isNavigationLinkToFilterActive = true
//                    }) { Image(systemName: viewModel.hasFilter ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle") }
//                }
//            })
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
                .alert("Your follow request has been sent; when accepted, the user will be displayed as \"Following\" in this list.", isPresented: $viewModel.shouldShowFollowedAlert) {
                    Button("OK", role: .cancel) { }
                }
        }
        .alert("Error in following the user. Please try again", isPresented: $viewModel.followingErrorAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        UsersView()
            .environmentObject(GlobalData.sample)
    }
}
