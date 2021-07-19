//
//  SearchViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/15/21.
//

import SwiftUI

class SearchViewModel: ObservableObject {
    let defaults = UserDefaults(suiteName: "group.com.spneshaei.MemoReminder") ?? .standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    var isSample = false
    
    @Published var shouldShowPredeterminedUsers = false
    @Published var predeterminedUsers: [User] = []
    
    init(predeterminedUsers: [User]) {
        self.predeterminedUsers = predeterminedUsers
        self.shouldShowPredeterminedUsers = true
        self.users = []
        self.friends = []
        self.currentUser = User(id: 0)
    }
    
    @Published var users: [User] {
        didSet {
            defaults.set(try? encoder.encode(users), forKey: "SearchViewModel_users")
        }
    }
    
    @Published var friends: [User] {
        didSet {
            defaults.set(try? encoder.encode(friends), forKey: "SearchViewModel_friends")
        }
    }
    
    @Published var currentUser: User {
        didSet {
            defaults.set(try? encoder.encode(currentUser), forKey: "ProfileViewModel_user")
        }
    }
    
    init() {
        if let users = try? decoder.decode([User].self, from: defaults.data(forKey: "SearchViewModel_users") ?? Data()) {
            self.users = users
        } else {
            self.users = []
        }
        if let friends = try? decoder.decode([User].self, from: defaults.data(forKey: "SearchViewModel_friends") ?? Data()) {
            self.friends = friends
        } else {
            self.friends = []
        }
        if let currentUser = try? decoder.decode(User.self, from: defaults.data(forKey: "ProfileViewModel_user") ?? Data()) {
            self.currentUser = currentUser
        } else {
            self.currentUser = User(id: 0)
        }
    }
    
    @Published var searchPredicate = ""
    @Published var shouldShowFollowedAlert = false
    @Published var showingLoadingUsersErrorAlert = false
    @Published var followingErrorAlert = false
    
    @Published var showOnlyTheUsersIFollow = false
    @Published var showOnlyTheUsersInMyContacts = false
    
    var hasFilter: Bool {
        return showOnlyTheUsersIFollow || showOnlyTheUsersInMyContacts
    }
    
    var filteredUsers: [User] {
        if shouldShowPredeterminedUsers {
            return predeterminedUsers
        } else {
            var result = searchPredicate.isEmpty ? users : users.filter { $0.username.lowercased().contains(searchPredicate.lowercased())
                || $0.firstName.lowercased().contains(searchPredicate.lowercased()) || $0.lastName.lowercased().contains(searchPredicate.lowercased()) }
            if showOnlyTheUsersIFollow {
                result = result.filter { currentUser.followingIDs.contains($0.id) }
            }
            if showOnlyTheUsersInMyContacts {
                // TODO: Filter!
            }
            return result
        }
    }
    
    func loadUser(globalData: GlobalData) async throws {
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "memo-user/\(globalData.userID)/", body: "", method: .get)
        main {
            self.currentUser = User.loadFromJSON(jsonString: resultString)
        }
    }
    
    func loadUsers(globalData: GlobalData) async throws {
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "memo-user/", body: "", method: .get)
        main {
            let results = JSON(parseJSON: resultString)["results"]
            self.friends = []
            self.users = results.arrayValue.map { result -> User in
                let user = User(id: result["id"].intValue)
                user.username = result["username"].stringValue
                user.firstName = result["first_name"].stringValue
                user.lastName = result["last_name"].stringValue
                user.email = result["email"].stringValue
                user.phoneNumber = result["phone_number"].stringValue
                user.birthday = result["birthday_date"].stringValue
                if user.username == globalData.username {
                    self.friends.append(user)
                }
                return user
            }
            .filter { $0.username != globalData.username }
        }
    }
    
    func follow(user: User, globalData: GlobalData) async throws {
        guard !isSample else { return }
        let body: JSON = [
            "to_user": user.id
        ]
        guard let bodyString = body.rawString() else { return }
        try await Rester.rest(endPoint: "friend-request/?token=\(globalData.token)", body: bodyString, method: .post)
    }
    
    static var sample: SearchViewModel {
        let viewModel = SearchViewModel()
        viewModel.isSample = true
        viewModel.users = [User.sample, User.sample]
        viewModel.friends = []
        return viewModel
    }
}
