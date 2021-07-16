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
    @Published var user = User()
    @Published var followRequests: [User] = []
    @Published var shouldShowAcceptSuccessAlert = false
    @Published var shouldShowAcceptErrorAlert = false
    @Published var shouldShowLoadingDataErrorAlert = false
    
    func loadMyMemories(globalData: GlobalData) async throws {
        // TODO: All the extra details from memories!!
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
                let user = User(id: "\(result["id"].stringValue)")
                user.username = result["username"].stringValue
                user.firstName = result["first_name"].stringValue
                user.lastName = result["last_name"].stringValue
                user.email = result["email"].stringValue
                user.phoneNumber = result["phone_number"].stringValue
                user.birthday = result["birthday_date"].stringValue
                return user
            }.first ?? User()
        }
    }
    
    func loadFollowRequests(globalData: GlobalData) async throws {
        guard !isSample else { return }
        // TODO: Next line to prevent wrongities
        guard false else { return }
        let resultString = try await Rester.rest(endPoint: "friend-request/?token=\(globalData.token)", body: "", method: .get)
        main {
            let results = JSON(parseJSON: resultString)["results"]
            self.followRequests = results.arrayValue.map { result -> User in
                let user = User(id: "\(result["id"].stringValue)")
                user.username = result["username"].stringValue
                user.firstName = result["first_name"].stringValue
                user.lastName = result["last_name"].stringValue
                user.email = result["email"].stringValue
                user.phoneNumber = result["phone_number"].stringValue
                user.birthday = result["birthday_date"].stringValue
                // TODO: This doesn't work! Merge has not been done in the backend API
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
        try await Rester.rest(endPoint: "friend-request/\(Int(user.id) ?? -1)/?token=\(globalData.token)", body: bodyString, method: .patch)
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
