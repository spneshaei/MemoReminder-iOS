//
//  AcceptRejectUserCell.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/16/21.
//

import SwiftUI
import URLImage

struct AcceptRejectUserCell: View {
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool { colorScheme == .dark }
    
    var user: User
    @ObservedObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var globalData: GlobalData
    var shouldShowProfilePicture: Bool
    
    init(user: User, profileViewModel: ProfileViewModel, shouldShowProfilePicture: Bool = true) {
        self.user = user
        self.profileViewModel = profileViewModel
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
            Button("ACCEPT") {
                async {
                    do {
                        try await profileViewModel.accept(user: user, globalData: globalData)
                        try await profileViewModel.loadFollowRequests(globalData: globalData)
                        main { profileViewModel.shouldShowAcceptSuccessAlert = true }
                    } catch {
                        main { profileViewModel.shouldShowAcceptErrorAlert = true }
                    }
                }
            }
            .font(.system(size: 17, weight: .bold, design: .default))
            .buttonStyle(.bordered)
            .padding()
            
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(isDarkMode ? Color(red: 231/255, green: 133/255, blue: 54/255) : Color(red: 247/255, green: 207/255, blue: 71/255))
        .listRowBackground(isDarkMode ? Color.black : Color.white)
        .modifier(MemoryCardModifier())
        .padding(.all, 10)
    }
}

struct AcceptRejectUserCell_Previews: PreviewProvider {
    static var previews: some View {
        AcceptRejectUserCell(user: .sample, profileViewModel: .sample)
    }
}
