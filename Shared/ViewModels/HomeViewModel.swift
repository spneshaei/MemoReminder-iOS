//
//  HomeViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    let defaults = UserDefaults(suiteName: "group.com.spneshaei.MemoReminder") ?? .standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    var isSample = false
    
    @Published var topMemories: [Memory] {
        didSet {
            defaults.set(try? encoder.encode(topMemories), forKey: "HomeViewModel_topMemories")
        }
    }
    
    @Published var mentionedMemories: [Memory] {
        didSet {
            defaults.set(try? encoder.encode(topMemories), forKey: "HomeViewModel_mentionedMemories")
        }
    }
    
    init() {
        if let topMemories = try? decoder.decode([Memory].self, from: defaults.data(forKey: "HomeViewModel_topMemories") ?? Data()) {
            self.topMemories = topMemories
        } else {
            self.topMemories = []
        }
        if let mentionedMemories = try? decoder.decode([Memory].self, from: defaults.data(forKey: "HomeViewModel_mentionedMemories") ?? Data()) {
            self.mentionedMemories = mentionedMemories
        } else {
            self.mentionedMemories = []
        }
    }
    
    func loadMentionedMemories(globalData: GlobalData) async throws {
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "tagged-post/?token=\(globalData.token)", body: "", method: .get)
        main {
            let results = JSON(parseJSON: resultString)["results"]
            self.mentionedMemories = results.arrayValue.map { result -> Memory in
                return Memory.memoryFromResultJSON(result, currentUserID: globalData.userID)
            }
        }
    }
    
    func loadTopMemories(globalData: GlobalData) async throws {
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "top-post", body: "", method: .get)
        main {
            let results = JSON(parseJSON: resultString)["results"]
            self.topMemories = results.arrayValue.map { result -> Memory in
                return Memory.memoryFromResultJSON(result, currentUserID: globalData.userID)
            }
        }
    }

    
    func addMemory(title: String, contents: String, tags: [Tag], mentionedUsers: [User], latitude: Double, longitude: Double, privacyStatus: Memory.PrivacyStatus, globalData: GlobalData) async throws {
        guard !isSample else { return }
        let body: JSON = [
            "title": title,
            "text": contents,
            "tags": tags.map { $0.id },
            "tagged_people": mentionedUsers.map { $0.id },
            "lat": latitude,
            "lon": longitude,
            "mode": privacyStatus == .privateStatus ? "private" : "public"
        ]
        guard let bodyString = body.rawString() else { return }
        try await Rester.rest(endPoint: "post/?token=\(globalData.token)", body: bodyString, method: .post)
    }
    
    static var sample: HomeViewModel {
        let viewModel = HomeViewModel()
        viewModel.isSample = true
        viewModel.topMemories = [Memory.sample, Memory.sample]
        return viewModel
    }
}
