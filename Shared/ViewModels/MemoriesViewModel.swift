//
//  MemoriesViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

class MemoriesViewModel: ObservableObject {
    var isSample = false
    @Published var memories: [Memory] = []
    @Published var searchPredicate = ""
    
    var filteredMemories: [Memory] {
        searchPredicate.isEmpty ? memories : memories.filter { $0.title.lowercased().contains(searchPredicate.lowercased())
            || $0.contents.lowercased().contains(searchPredicate.lowercased()) || $0.creatorUsername.lowercased().contains(searchPredicate.lowercased()) }
    }
    
    
    
    func loadMemories(globalData: GlobalData) async throws {
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "post/?token=\(globalData.token)", body: "", method: .get)
        main {
            let results = JSON(parseJSON: resultString)["results"]
            self.memories = results.arrayValue.map { result -> Memory in
                return Memory.memoryFromResultJSON(result, currentUserID: globalData.userID)
            }
        }
    }
    
    // TODO: Forgot password?
    
    static var sample: MemoriesViewModel {
        let viewModel = MemoriesViewModel()
        viewModel.isSample = true
        viewModel.memories = [Memory.sample]
        return viewModel
    }
}
