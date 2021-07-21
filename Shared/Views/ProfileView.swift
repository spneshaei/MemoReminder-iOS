//
//  ProfileView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI
import ActivityIndicatorView

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool { colorScheme == .dark }
    
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var globalData: GlobalData
    @EnvironmentObject var mainAppViewModel: MainAppViewModel
    @State var editMode = false {
        didSet {
            if editMode == false {
                changePasswordMode = false
            }
        }
    }
    @State var changePasswordMode = false
    @State var firstName = ""
    @State var username = ""
    @State var email = ""
    @State var birthDate = Date()
    @State var newPassword = ""
    @State var showActivityIndicatorView = false
    @State var showLogoutConfirmationAlert = false
    @State var isNavigationToNotificationSchedulingViewActive = false
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        UITextView.appearance().backgroundColor = .clear
    }
    
    fileprivate func logout() async {
        main { showActivityIndicatorView = true }
        try? await viewModel.logout(globalData: globalData)
        main {
            showActivityIndicatorView = false
            globalData.logout()
            withAnimation {
                mainAppViewModel.currentView = .login
            }
        }
    }
    
    fileprivate func doneTapped() async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.editUserDetails(id: viewModel.user.id, firstName: firstName, username: username, email: email, birthday: birthDate, newPassword: newPassword, globalData: globalData)
            main {
                viewModel.user.username = username
                viewModel.user.email = email
                viewModel.user.firstName = firstName
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd"
                viewModel.user.birthday = dateFormatter.string(from: birthDate)
                showActivityIndicatorView = false
                withAnimation { editMode = false }
            }
        } catch {
            main {
                showActivityIndicatorView = false
                viewModel.shouldShowEditProfileErrorAlert = true
            }
        }
    }
    
    fileprivate func populateTextFields() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        username = viewModel.user.username
        email = viewModel.user.email
        firstName = viewModel.user.firstName
        birthDate = dateFormatter.date(from: viewModel.user.birthday) ?? Date()
        newPassword = ""
    }
    
    fileprivate func reloadData() async {
        populateTextFields()
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.loadUser(globalData: globalData)
            try await viewModel.loadFollowRequests(globalData: globalData)
            try await viewModel.loadMyMemories(globalData: globalData)
            main {
                populateTextFields()
                showActivityIndicatorView = false
            }
        } catch {
            main {
                populateTextFields()
                showActivityIndicatorView = false
                viewModel.shouldShowLoadingDataErrorAlert = true
            }
        }
    }
    
    var body: some View {
        ZStack {
            List {
                ProfilePictureAndNameView(profilePictureURL: viewModel.user.profilePictureURL, name: $firstName, editMode: editMode)
                    .listRowSeparator(editMode ? .visible : .hidden)
                if editMode {
                    VStack(alignment: .leading) {
                        Text("Username")
                        TextField(username, text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .id(0) // For SDK Bug!
                    }
                    VStack(alignment: .leading) {
                        Text("Email")
                        TextField(email, text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .id(1) // SDK Bug!
                    }
                    DatePicker(selection: $birthDate, in: ...Date(), displayedComponents: .date) {
                        Text("Birthday")
                    }
                    Button(action: {
                        withAnimation { changePasswordMode.toggle() }
                    }) {
                        HStack {
                            Text("Set a new password")
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: changePasswordMode ? "arrow.up" : "arrow.right")
                        }
                    }
                    if changePasswordMode {
                        SecureField("Enter your new password", text: $newPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .id(2)
                    }
                }
                ThreeStatsView(user: viewModel.user)
                if !viewModel.followRequests.isEmpty {
                    Text("Follow requests").font(.title).bold()
                        .listRowSeparator(.hidden)
                    ForEach(viewModel.followRequests) { user in
                        AcceptRejectUserCell(user: user, profileViewModel: viewModel)
                    }
                }
                Text("My created memories").font(.title).bold()
                    .listRowSeparator(.hidden)
                ForEach(viewModel.myMemories) { memory in
                    ZStack {
                        MemoryCell(memory: memory, shouldShowProfilePicture: false)
                            .listRowSeparator(.hidden)
                        NavigationLink(destination: MemoryView(memory: memory, imageLink: memory.imageLink, numberOfLikes: memory.numberOfLikes, hasCurrentUserLiked: memory.hasCurrentUserLiked)) {
                            EmptyView()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowSeparator(.hidden)
                    }
//                    .listRowBackground(isDarkMode ? Color.black : Color.white)
                    .listRowSeparator(.hidden)
                }
                
            }
            .alert("Accept was successful", isPresented: $viewModel.shouldShowAcceptSuccessAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Accept failed. Please try again", isPresented: $viewModel.shouldShowAcceptErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Editing profile details failed. Please try again", isPresented: $viewModel.shouldShowEditProfileErrorAlert) {
                Button("OK", role: .cancel) { }
            }
//                .alert("Are you sure you want to log out?", isPresented: $showLogoutConfirmationAlert) {
//                    Button("Yes", role: .destructive) {
//                        async { await logout() }
//                    }
//                    Button("No", role: .cancel) { }
//                }
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
            .navigationBarItems(leading: Group {
                if editMode {
                    Button(action: {
                        withAnimation { editMode = false }
                        populateTextFields()
                    }) {
                        Text("Cancel").bold()
                    }
                }
            }, trailing: HStack(spacing: 10) {
                if !editMode {
                    Button(action: {
                        guard !showActivityIndicatorView else { return }
                        showLogoutConfirmationAlert = true
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                    .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirmationAlert, titleVisibility: .visible) {
                        Button("Yes", role: .destructive) {
                            async { await logout() }
                        }
                        Button("No", role: .cancel) { }
                    }
                    
                    NavigationLink(destination: RemindersView(), isActive: $isNavigationToNotificationSchedulingViewActive) {
                        Button(action: {
                            isNavigationToNotificationSchedulingViewActive = true
                        }) {
                            Image(systemName: "clock")
                        }
                    }
                }
                
                Button(action: {
                    guard !showActivityIndicatorView else { return }
                    if editMode == false {
                        withAnimation {
                            editMode = true
                        }
                    } else {
                        async { await doneTapped() }
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel.sample)
            .preferredColorScheme(.dark)
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
            HStack {
                Text("Welcome,")
                if editMode {
                    TextField("Enter your name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(name)
                }
                Spacer()
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
