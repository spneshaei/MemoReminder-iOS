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
    
    func loadTopMemories() async {
        guard !isSample else { return }
    }
    
    func loadFriendsMemories() async {
        guard !isSample else { return }
    }
    
    func sendMemory(title: String, contents: String, globalData: GlobalData) async throws {
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
