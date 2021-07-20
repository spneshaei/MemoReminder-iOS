//
//  ContactsSuggestionsView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI
import ActivityIndicatorView

struct ContactsSuggestionsView: View {
    @EnvironmentObject var globalData: GlobalData
    
    @ObservedObject var viewModel: ContactsSuggestionsViewModel
    @ObservedObject var searchViewModel: UsersViewModel
    @State var showActivityIndicatorView = false
    @State var showingLoadingContactsErrorAlert = false
    
    func reloadData() async {
        do {
            main { showActivityIndicatorView = true }
            viewModel.resetUsers()
            for contactFirstName in viewModel.contactFirstNames {
                try await viewModel.loadUsers(firstName: contactFirstName, globalData: globalData)
            }
            main { showActivityIndicatorView = false }
        } catch {
            main {
                showActivityIndicatorView = false
                showingLoadingContactsErrorAlert = true
            }
        }
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.contactFirstNames, id: \.self) { contactFirstName in
                    if !viewModel.users(firstName: contactFirstName).isEmpty {
                        Section(header: Text("Users with name \(contactFirstName)").font(.headline)) {
                            ForEach(viewModel.users(firstName: contactFirstName)) { user in
                                SearchUserCell(user: user, searchViewModel: searchViewModel, shouldSelectUsers: false)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .task { await reloadData() }
            .refreshable { await reloadData() }
            .alert("Error in loading the users. Please pull to refresh to try again", isPresented: $showingLoadingContactsErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }
        .navigationBarTitle("Contacts suggestions")
    }
}

struct ContactsSuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsSuggestionsView(viewModel: .sample, searchViewModel: .sample)
            .environmentObject(GlobalData.sample)
    }
}
