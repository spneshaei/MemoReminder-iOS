//
//  HomeViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    var isSample = false
    @Published var topMemories: [Memory] = []
    @Published var friendsMemories: [Memory] = []
    
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

    
    func addMemory(title: String, contents: String, globalData: GlobalData) async throws {
        // TODO: Tagging!
        guard !isSample else { return }
        let body: JSON = [
            "title": title,
            "text": contents,
            "tags": [] // TODO: This!
        ]
        guard let bodyString = body.rawString() else { return }
        try await Rester.rest(endPoint: "post/?token=\(globalData.token)", body: bodyString, method: .post)
    }
    
    static var sample: HomeViewModel {
        let viewModel = HomeViewModel()
        viewModel.isSample = true
        viewModel.topMemories = [Memory.sample, Memory.sample]
        viewModel.friendsMemories = [Memory.sample, Memory.sample]
        return viewModel
    }
}
