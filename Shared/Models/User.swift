//
//  User.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import Foundation

class User: Identifiable, Codable {
    var id: String
    
    var username = ""
    var firstName = ""
    var lastName = ""
    var email = ""
    var birthday = ""
    var phoneNumber = ""
    var password = ""
    var profilePictureURL = ""
    var numberOfMemories = 0
    var numberOfLikes = 0
    var numberOfComments = 0
    
    init(id: String) {
        self.id = id
    }
    
    convenience init() {
        self.init(id: UUID().uuidString)
    }
    
    static var sample: User {
        let user = User()
        user.username = "seyyedparsa"
        user.firstName = "Seyed Parsa"
        user.lastName = "Neshaei"
        user.email = "spn@spn.spn"
        user.birthday = "1943/23/12"
        user.phoneNumber = "12345678911"
        user.profilePictureURL = "" // adjust this!
        user.numberOfMemories = 12
        user.numberOfLikes = 125
        user.numberOfComments = 32
        return user
    }
    
    // TODO: On net disconnection error
    // TODO: Distinguish validation and repeated account error and...
    enum AuthenticationStatus: Error {
        case invalidData
        case failed
        case success
    }
    
    // TODO: Email and password validation in client
    static func signUp(username: String, firstName: String, lastName: String, birthday: String, password: String, phoneNumber: String, email: String) async -> AuthenticationStatus {
        let body: JSON = [
            "username": username,
            "first_name": firstName,
            "birthday_date": birthday,
            "last_name": lastName,
            "password": password,
            "phone_number": phoneNumber,
            "email": email
        ]
        guard let bodyString = body.rawString() else { return AuthenticationStatus.invalidData }
        do {
            try await Rester.rest(endPoint: "memo-user/", body: bodyString, method: .post)
            return .success
        } catch {
            return .failed
        }
    }
    
    static func login(username: String, password: String, globalData: GlobalData) async -> AuthenticationStatus {
        let body: JSON = [
            "username": username,
            "password": password
        ]
        guard let bodyString = body.rawString() else { return AuthenticationStatus.invalidData }
        do {
            let result = try await Rester.rest(endPoint: "login/", body: bodyString, method: .post)
            main {
                let json = JSON(parseJSON: result)
                globalData.loggedIn = true
                globalData.userID = json["id"].intValue
                globalData.username = json["username"].stringValue
                globalData.firstName = json["first_name"].stringValue
                globalData.lastName = json["last_name"].stringValue
                globalData.email = json["email"].stringValue
                globalData.phoneNumber = json["phone_number"].stringValue
                globalData.birthday = json["birthday_date"].stringValue
                globalData.token = json["token"].stringValue
            }
            return .success
        } catch {
            return .failed
        }
    }
}
