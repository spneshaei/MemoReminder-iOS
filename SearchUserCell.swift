//
//  SearchUserCell.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/15/21.
//

import SwiftUI
import URLImage

struct SearchUserCell: View {
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool { colorScheme == .dark }
    
    var user: User
    @ObservedObject var searchViewModel: UsersViewModel
    @EnvironmentObject var globalData: GlobalData
    @State var followingErrorAlert = false
    @State var shouldShowFollowedAlert = false
    var shouldShowProfilePicture: Bool
    var shouldSelectUsers = false
    
    var hasFollowed: Bool {
        searchViewModel.friends.contains { $0.username == user.username }
    }
    
    init(user: User, searchViewModel: UsersViewModel, shouldSelectUsers: Bool = false, shouldShowProfilePicture: Bool = true) {
        self.user = user
        self.searchViewModel = searchViewModel
        self.shouldSelectUsers = shouldSelectUsers
        self.shouldShowProfilePicture = shouldShowProfilePicture
    }
    
    var body: some View {
        HStack(alignment: .center) {
            if URL(string: user.profilePictureURL) != nil {
                URLImage(URL(string: user.profilePictureURL)!) { urlImage in
                    urlImage.resizable()
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .padding(.all, 20)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(user.firstName)
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .foregroundColor(.black)
                Text(user.username)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 70/255, green: 70/255, blue: 70/255))
            }
            .padding(20)
            .alert("Error in following the user. Please try again", isPresented: $followingErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            
            Spacer()
            if !shouldSelectUsers {
                if hasFollowed {
                    Text("Following")
                    .font(.system(size: 17, weight: .bold, design: .default))
                    .buttonStyle(.plain)
                    .padding()
                } else {
                    Button(action: {
                        async {
                            do {
                                try await searchViewModel.follow(user: user, globalData: globalData)
                                main { shouldShowFollowedAlert = true }
                            } catch {
                                main { followingErrorAlert = true }
                            }
                        }
                    }, label: { Text("FOLLOW").bold().foregroundColor(isDarkMode ? Color(red: 0.05, green: 0.05, blue: 0.95) : .blue) })
                    .font(.system(size: 17, weight: .bold, design: .default))
                    .buttonStyle(.bordered)
                    .padding()
                }
            }
        }
        .alert("Your follow request has been sent; when accepted, the user will be displayed as \"Following\" in this list.", isPresented: $shouldShowFollowedAlert) {
            Button("OK", role: .cancel) { }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(isDarkMode ? Color(red: 231/255, green: 133/255, blue: 54/255) : Color(red: 247/255, green: 207/255, blue: 71/255))
        .listRowBackground(isDarkMode ? Color.black : Color.white)
        .modifier(MemoryCardModifier())
        .padding(.all, 10)
        .listRowSeparator(.hidden)
    }
}

struct UserCell_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserCell(user: User.sample, searchViewModel: .sample)
            .preferredColorScheme(.dark)
            .environmentObject(GlobalData.sample)
    }
}
