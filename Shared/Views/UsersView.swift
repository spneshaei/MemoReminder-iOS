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
    @State var shouldShowContactsLoadingErrorAlert = false
    @State var shouldShowContactsAccessDeniedAlert = false
    
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
                print("Contacts Access Granted")
                fetchContacts { result in
                    switch result {
                        case .success(let contacts):
                            // Do your thing here with [CNContacts] array
                            main {
                                contactsSuggestionViewModel.contacts = contacts
                                shouldNavigateToFindContactsPage = true
                            }
                        case .failure(_):
                            main {
                                shouldShowContactsLoadingErrorAlert = true
                            }
                    }
                }
            } else {
                print("Contacts Access Denied")
                main {
                    shouldShowContactsAccessDeniedAlert = true
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            EmptyView()
                .alert("You've previously denied the app's access to your contacts. Please grant the app access to your contacts by opening the Settings app.", isPresented: $shouldShowContactsAccessDeniedAlert) {
                    Button("OK", role: .cancel) {
                        self.mode.wrappedValue.dismiss()
                    }
                }
            EmptyView()
                .alert("Error in loading contacts. Please try again.", isPresented: $shouldShowContactsLoadingErrorAlert) {
                    Button("OK", role: .cancel) {
                        self.mode.wrappedValue.dismiss()
                    }
                }
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
            .navigationBarItems(trailing: HStack {
                if !viewModel.shouldShowPredeterminedUsers {
                    NavigationLink(destination: ContactsSuggestionsView(viewModel: contactsSuggestionViewModel, searchViewModel: viewModel), isActive: $shouldNavigateToFindContactsPage) {
                        Button(action: { navigateToFindContactsPage() }) {
                            Image(systemName: "wand.and.stars")
                                .accessibility(hint: Text("See contacts suggestions"))
                        }
                    }
                }
            })
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
                
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        UsersView()
            .environmentObject(GlobalData.sample)
    }
}
