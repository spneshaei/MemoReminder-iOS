//
//  GlobalData.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/13/21.
//

import SwiftUI

class GlobalData: ObservableObject {
    let defaults = UserDefaults(suiteName: "group.com.spneshaei.MemoReminder") ?? .standard
    
    @Published var loggedIn: Bool {
        didSet {
            defaults.set(loggedIn, forKey: "GlobalData_loggedIn")
        }
    }
    @Published var userID: Int {
        didSet {
            defaults.set(userID, forKey: "GlobalData_userID")
        }
    }
    @Published var username: String {
        didSet {
            defaults.set(username, forKey: "GlobalData_username")
        }
    }
    @Published var firstName: String {
        didSet {
            defaults.set(firstName, forKey: "GlobalData_firstName")
        }
    }
    @Published var lastName: String {
        didSet {
            defaults.set(lastName, forKey: "GlobalData_lastName")
        }
    }
    @Published var email: String {
        didSet {
            defaults.set(email, forKey: "GlobalData_email")
        }
    }
    @Published var phoneNumber: String {
        didSet {
            defaults.set(phoneNumber, forKey: "GlobalData_phoneNumber")
        }
    }
    @Published var birthday: String {
        didSet {
            defaults.set(birthday, forKey: "GlobalData_birthday")
        }
    }
    @Published var token: String {
        didSet {
            defaults.set(token, forKey: "GlobalData_token")
        }
    }
    
    init() {
        loggedIn = defaults.bool(forKey: "GlobalData_loggedIn")
        userID = defaults.integer(forKey: "GlobalData_userID")
        username = defaults.string(forKey: "GlobalData_username") ?? ""
        firstName = defaults.string(forKey: "GlobalData_firstName") ?? ""
        lastName = defaults.string(forKey: "GlobalData_lastName") ?? ""
        email = defaults.string(forKey: "GlobalData_email") ?? ""
        phoneNumber = defaults.string(forKey: "GlobalData_phoneNumber") ?? ""
        birthday = defaults.string(forKey: "GlobalData_birthday") ?? ""
        token = defaults.string(forKey: "GlobalData_token") ?? ""
    }
    
    fileprivate func clearGlobalDataItems() {
        loggedIn = false
        userID = 0
        username = ""
        firstName = ""
        lastName = ""
        email = ""
        phoneNumber = ""
        birthday = ""
        token = ""
    }
    
    func clearUserDefaults() {
        defaults.set(Data(), forKey: "NotificationRemindersViewModel_reminders")
        defaults.set(Data(), forKey: "TagsViewModel_allTags")
        defaults.set(Data(), forKey: "SearchViewModel_users")
        defaults.set(Data(), forKey: "SearchViewModel_friends")
        defaults.set(Data(), forKey: "ProfileViewModel_user")
        defaults.set(Data(), forKey: "HomeViewModel_topMemories")
        defaults.set(Data(), forKey: "HomeViewModel_mentionedMemories")
        defaults.set(Data(), forKey: "MemoriesViewModel_memories")
        defaults.set(Data(), forKey: "ProfileViewModel_myMemories")
        defaults.set(Data(), forKey: "ProfileViewModel_user")
        defaults.set(Data(), forKey: "ProfileViewModel_followRequests")
    }
    
    func logout() {
        clearGlobalDataItems()
        clearUserDefaults()
    }
    
    static var sample: GlobalData {
        GlobalData()
    }
}
