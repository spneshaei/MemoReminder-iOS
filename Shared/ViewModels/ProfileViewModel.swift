//
//  ProfileViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    var isSample = false
    @Published var myMemories: [Memory] = []
    @Published var user = User(id: 1)
    @Published var followRequests: [User] = []
    @Published var shouldShowAcceptSuccessAlert = false
    @Published var shouldShowAcceptErrorAlert = false
    @Published var shouldShowLoadingDataErrorAlert = false
    
    func loadMyMemories(globalData: GlobalData) async throws {
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "post/?token=\(globalData.token)", body: "", method: .get)
        main {
            let results = JSON(parseJSON: resultString)["results"]
            self.myMemories = results.arrayValue.map { result -> Memory in
                return Memory.memoryFromResultJSON(result, currentUserID: globalData.userID)
            }.filter { $0.creatorUsername == globalData.username }
        }
    }
    
    func loadUser(globalData: GlobalData) async throws {
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "memo-user/?username=\(globalData.username)", body: "", method: .get)
        main {
            let results = JSON(parseJSON: resultString)["results"]
            self.user = results.arrayValue.map { result -> User in
                let user = User(id: result["id"].intValue)
                user.username = result["username"].stringValue
                user.firstName = result["first_name"].stringValue
                user.lastName = result["last_name"].stringValue
                user.email = result["email"].stringValue
                user.phoneNumber = result["phone_number"].stringValue
                user.birthday = result["birthday_date"].stringValue
                user.numberOfLikes = result["likes_received_count"].intValue
                user.numberOfMemories = result["posts_count"].intValue
                user.numberOfComments = result["comments_received_count"].intValue
                return user
            }.first ?? User(id: 1)
        }
    }
    
    func loadFollowRequests(globalData: GlobalData) async throws {
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "friend-request/?token=\(globalData.token)", body: "", method: .get)
        main {
            let results = JSON(parseJSON: resultString)["results"]
            self.followRequests = results.arrayValue.map { result -> User in
                let fromUser = result["from_user"]
                let user = User(id: fromUser["id"].intValue)
                user.username = fromUser["username"].stringValue
                user.firstName = fromUser["first_name"].stringValue
                user.lastName = fromUser["last_name"].stringValue
                user.followRequestID = result["id"].intValue
                return user
            }
            .filter { $0.username != globalData.username }
        }
    }
    
    func accept(user: User, globalData: GlobalData) async throws {
        guard !isSample else { return }
        let body: JSON = [
            "status": "accepted"
        ]
        guard let bodyString = body.rawString() else { return }
        try await Rester.rest(endPoint: "friend-request/\(user.followRequestID)/?token=\(globalData.token)", body: bodyString, method: .patch)
    }
    
    func logout(globalData: GlobalData) async throws {
        guard !isSample else { return }
        try await Rester.rest(endPoint: "logout/?token=\(globalData.token)", body: "", method: .post)
    }
    
    // TODO: We don't have reject friend request!
    
    static var sample: ProfileViewModel {
        let viewModel = ProfileViewModel()
        viewModel.isSample = true
        viewModel.myMemories = [Memory.sample]
        viewModel.followRequests = [User.sample]
        viewModel.user = User.sample
        return viewModel
    }
}
