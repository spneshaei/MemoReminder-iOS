//
//  User.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import Foundation

class User: Identifiable, Codable {
    var id: Int
    
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
    var followingIDs: [Int] = []
    var followRequestID = -1
    
    init(id: Int) {
        self.id = id
    }
    
    static var sample: User {
        let user = User(id: 1)
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
        user.followingIDs = []
        user.followRequestID = -1 // not used in following acceptance or rejection...
        return user
    }
    
    enum AuthenticationStatus: Error {
        case invalidData
        case failed
        case success
    }
    
    static func loadFromJSON(jsonString resultString: String) -> User {
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
        user.followingIDs = result["friends"].arrayValue.map { $0.intValue }
        return user
    }
    
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
