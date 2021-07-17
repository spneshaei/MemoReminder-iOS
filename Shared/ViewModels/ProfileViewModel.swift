//
//  ProfileViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    var isSample = false
    
    @Published var myMemories: [Memory] {
        didSet {
            defaults.set(try? encoder.encode(myMemories), forKey: "ProfileViewModel_myMemories")
        }
    }
    
    @Published var user: User {
        didSet {
            defaults.set(try? encoder.encode(user), forKey: "ProfileViewModel_user")
        }
    }
    
    @Published var followRequests: [User] {
        didSet {
            defaults.set(try? encoder.encode(followRequests), forKey: "ProfileViewModel_followRequests")
        }
    }
    
    @Published var shouldShowAcceptSuccessAlert = false
    @Published var shouldShowAcceptErrorAlert = false
    @Published var shouldShowLoadingDataErrorAlert = false
    @Published var shouldShowEditProfileErrorAlert = false
    
    init() {
        if let myMemories = try? decoder.decode([Memory].self, from: defaults.data(forKey: "ProfileViewModel_myMemories") ?? Data()) {
            self.myMemories = myMemories
        } else {
            self.myMemories = []
        }
        if let user = try? decoder.decode(User.self, from: defaults.data(forKey: "ProfileViewModel_user") ?? Data()) {
            self.user = user
        } else {
            self.user = User(id: 2)
        }
        if let followRequests = try? decoder.decode([User].self, from: defaults.data(forKey: "ProfileViewModel_followRequests") ?? Data()) {
            self.followRequests = followRequests
        } else {
            self.followRequests = []
        }
    }
    
    func loadMyMemories(globalData: GlobalData) async throws {
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "post/?token=\(globalData.token)", body: "", method: .get)
        main {
            let results = JSON(parseJSON: resultString)["results"]
            self.myMemories = results.arrayValue.map { result -> Memory in
                return Memory.memoryFromResultJSON(result, currentUserID: globalData.userID)
            }.filter { $0.creatorUserID == globalData.userID }
        }
    }
    
    func loadUser(globalData: GlobalData) async throws {
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "memo-user/\(globalData.userID)/", body: "", method: .get)
        main {
            let result = JSON(parseJSON: resultString)
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
            self.user = user
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
    
    func editUserDetails(id: Int, firstName: String, username: String, email: String, birthday: Date, newPassword: String, globalData: GlobalData) async throws {
        guard !isSample else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let body: JSON
        if newPassword.isEmpty {
            body = [
                "first_name": firstName,
                "username": username,
                "email": email,
                "birthday": dateFormatter.string(from: birthday)
            ]
        } else {
            body = [
                "first_name": firstName,
                "username": username,
                "email": email,
                "birthday": dateFormatter.string(from: birthday),
                "password": newPassword
            ]
        }
        guard let bodyString = body.rawString() else { return }
        try await Rester.rest(endPoint: "memo-user/\(id)/?token=\(globalData.token)", body: bodyString, method: .patch)
    }
    
    func logout(globalData: GlobalData) async throws {
        guard !isSample else { return }
        try await Rester.rest(endPoint: "logout/?token=\(globalData.token)", body: "", method: .post)
    }
    
    static var sample: ProfileViewModel {
        let viewModel = ProfileViewModel()
        viewModel.isSample = true
        viewModel.myMemories = [Memory.sample]
        viewModel.followRequests = [User.sample]
        viewModel.user = User.sample
        return viewModel
    }
}
