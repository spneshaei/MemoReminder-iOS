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
    @ObservedObject var searchViewModel: SearchViewModel
    @EnvironmentObject var globalData: GlobalData
    var shouldShowProfilePicture: Bool
    
    var hasFollowed: Bool {
        searchViewModel.friends.contains { $0.username == user.username }
    }
    
    init(user: User, searchViewModel: SearchViewModel, shouldShowProfilePicture: Bool = true) {
        self.user = user
        self.searchViewModel = searchViewModel
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
            }.padding(20)
            Spacer()
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
                            main { searchViewModel.shouldShowFollowedAlert = true }
                        } catch {
                            main { searchViewModel.followingErrorAlert = true }
                        }
                    }
                }, label: { Text("FOLLOW").bold().foregroundColor(isDarkMode ? Color(red: 0.05, green: 0.05, blue: 0.95) : .blue) })
                .font(.system(size: 17, weight: .bold, design: .default))
                .buttonStyle(.bordered)
                .padding()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(isDarkMode ? Color.orange : Color(red: 247/255, green: 207/255, blue: 71/255))
        .opacity(0.8)
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
