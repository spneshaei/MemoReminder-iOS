//
//  ProfileView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI
import ActivityIndicatorView

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var globalData: GlobalData
    @EnvironmentObject var mainAppViewModel: MainAppViewModel
    @State var editMode = false
    @State var birthDate = Date() // TODO: This should be linked to the real birthday
    @State var showActivityIndicatorView = false
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        UITextView.appearance().backgroundColor = .clear
    }
    
    fileprivate func logout() async {
        // viewModel.logout(globalData: globalData)
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.logout(globalData: globalData)
            main {
                showActivityIndicatorView = false
                globalData.logout()
                withAnimation {
                    mainAppViewModel.currentView = .login
                }
            }
        } catch {
            main {
                showActivityIndicatorView = false
                viewModel.shouldShowLoadingDataErrorAlert = true
            }
        }
    }
    
    fileprivate func reloadData() async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.loadUser(globalData: globalData)
            try await viewModel.loadFollowRequests(globalData: globalData)
            try await viewModel.loadMyMemories(globalData: globalData)
            main { showActivityIndicatorView = false }
        } catch {
            main {
                showActivityIndicatorView = false
                viewModel.shouldShowLoadingDataErrorAlert = true
            }
        }
    }
    
    var body: some View {
        // TODO: The real big numbers in this page are not shown :(
        // TODO: Tags and uploading files to memories
        // TODO: Likes and comments
        NavigationView {
            ZStack {
                List {
                    ProfilePictureAndNameView(profilePictureURL: viewModel.user.profilePictureURL, name: $viewModel.user.firstName, editMode: editMode)
                        .listRowSeparator(editMode ? .visible : .hidden)
                    if editMode {
                        VStack(alignment: .leading) {
                            Text("USERNAME")
                            TextField(viewModel.user.username, text: $viewModel.user.username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading) {
                            Text("EMAIL")
                            TextField(viewModel.user.email, text: $viewModel.user.email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading) {
                            Text("PHONE NUMBER")
                            TextField(viewModel.user.phoneNumber, text: $viewModel.user.phoneNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        DatePicker(selection: $birthDate, in: ...Date(), displayedComponents: .date) {
                            Text("Birthday")
                        }
                    } else {
                        ThreeStatsView(user: viewModel.user)
                        if !viewModel.followRequests.isEmpty {
                            Text("Follow requests").font(.title).bold()
                                .listRowSeparator(.hidden)
                            ForEach(viewModel.followRequests) { user in
                                AcceptRejectUserCell(user: user, profileViewModel: viewModel)
                            }
                        }
                        // TODO: Misalignment in the stats view... in Simulator
                        Text("My created memories").font(.title).bold()
                            .listRowSeparator(.hidden)
                        ForEach(viewModel.myMemories) { memory in
                            NavigationLink(destination: MemoryView(memory: memory, numberOfLikes: memory.numberOfLikes, hasCurrentUserLiked: memory.hasCurrentUserLiked)) {
                                MemoryCell(memory: memory, shouldShowProfilePicture: false)
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                    
                }
                .alert("Accept was successful", isPresented: $viewModel.shouldShowAcceptSuccessAlert) {
                    Button("OK", role: .cancel) { }
                }
                .alert("Accept failed. Please try again", isPresented: $viewModel.shouldShowAcceptErrorAlert) {
                    Button("OK", role: .cancel) { }
                }
                // TODO: Separate alert for logout and loading data
//                .alert("Network operation failed. Please try again", isPresented: $viewModel.shouldShowLoadingDataErrorAlert) {
//                    Button("OK", role: .cancel) { }
//                }
                .task {
                    await reloadData()
                }
                .refreshable {
                    await reloadData()
                }
                .navigationBarTitle("My Profile")
                .navigationBarItems(trailing: HStack {
                    Button(action: {
                        async { await logout() }
                    }) {
                        Image(systemName: "arrow.right.circle")
                        // TODO: Better symbol for logout
                        // TODO: Confirmation upon log out!
                        // TODO: withAnimation in many places needed :)
                    }
                    
                    Button(action: {
                        withAnimation {
                            editMode.toggle()
                        }
                    }) {
                        if editMode {
                            Text("Done")
                                .fontWeight(.bold)
                        } else {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                })
                
                ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                    .frame(width: 100.0, height: 100.0)
                    .foregroundColor(.orange)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel.sample)
            .environmentObject(GlobalData.sample)
    }
}

struct ProfilePictureAndNameView: View {
    var profilePictureURL: String
    @Binding var name: String
    var editMode: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            if !profilePictureURL.isEmpty {
                AsyncImage(url: URL(string: profilePictureURL)!)
            }
            if editMode {
                TextField("Enter your name", text: $name)
                    .font(.title2)
            } else {
                Text(name)
                    .font(.title2)
            }
        }
    }
}

struct ThreeStatsView: View {
    var user: User
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                StatView(number: user.numberOfMemories, caption: "Memories")
                Divider()
                StatView(number: user.numberOfLikes, caption: "Likes")
                Divider()
                StatView(number: user.numberOfComments, caption: "Comments")
            }
            Divider()
        }
    }
}

struct StatView: View {
    var number: Int
    var caption: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(number)").font(.largeTitle).bold()
            Text(caption.uppercased()).font(.caption2).bold()
        }.padding()
    }
}
