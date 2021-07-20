//
//  ContactsSuggestionsViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI
import Contacts

class ContactsSuggestionsViewModel: ObservableObject {
    var isSample = false
    
    @Published var usersLoaded: [User] = []
    @Published var contacts: [CNContact] = []
    
    var contactFirstNames: [String] {
        contacts.map { $0.givenName }
    }
    
    func users(firstName: String) -> [User] {
        usersLoaded.filter { $0.firstName == firstName }
    }
    
    func resetUsers() {
        main { [weak self] in self?.usersLoaded = [] }
    }
    
    func loadUsers(firstName: String, globalData: GlobalData) async throws {
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "memo-user/?first_name__contains=\(firstName)", body: "", method: .get)
        main {
            let results = JSON(parseJSON: resultString)["results"]
            self.usersLoaded.append(contentsOf: results.arrayValue.map { result -> User in
                let user = User(id: result["id"].intValue)
                user.username = result["username"].stringValue
                user.firstName = result["first_name"].stringValue
                user.lastName = result["last_name"].stringValue
                user.email = result["email"].stringValue
                user.phoneNumber = result["phone_number"].stringValue
                user.birthday = result["birthday_date"].stringValue
                return user
            }
            .filter { $0.username != globalData.username })
        }
    }
    
    static var sample: ContactsSuggestionsViewModel {
        let viewModel = ContactsSuggestionsViewModel()
        viewModel.usersLoaded = [User.sample]
        viewModel.contacts = []
        return viewModel
    }
}
