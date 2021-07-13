//
//  ProfileView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State var editMode = false
    @State var birthDate = Date() // TODO: This should be linked to the real birthday
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
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
                    Text("My created memories").font(.title).bold()
                        .listRowSeparator(.hidden)
                    ForEach(viewModel.myMemories) { memory in
                        MemoryCell(memory: memory, shouldShowProfilePicture: false)
                    }
                }
                
            }
            .navigationBarTitle("My Profile")
            .navigationBarItems(trailing: Button(action: {
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
            })
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel.sample)
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
