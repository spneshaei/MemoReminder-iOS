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
    
    var body: some View {
        NavigationView {
            List {
                ProfilePictureAndNameView(profilePictureURL: viewModel.user.profilePictureURL, name: $viewModel.user.name, editMode: editMode)
                    .listRowSeparator(.hidden)
                ThreeStatsView(user: viewModel.user)
                Text("My created memories").font(.title).bold()
                    .listRowSeparator(.hidden)
                ForEach(viewModel.myMemories) { memory in
                    MemoryCell(memory: memory, shouldShowProfilePicture: false)
                }
            }
            .navigationBarTitle("My Profile")
            .navigationBarItems(trailing: Button(action: {
                editMode.toggle()
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
            TextField(name, text: $name)
                .font(.title)
                .lineLimit(2)
                .disabled(!editMode)
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
