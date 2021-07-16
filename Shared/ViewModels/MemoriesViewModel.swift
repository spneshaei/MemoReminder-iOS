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
        searchPredicate.isEmpty ? memories : memories.filter { $0.title.contains(searchPredicate)
            || $0.contents.contains(searchPredicate) || $0.creatorUsername.contains(searchPredicate) }
    }
    
    func loadMemories(globalData: GlobalData) async throws {
        // TODO: All the extra details from memories!!
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "post/?token=\(globalData.token)", body: "", method: .get)
        main {
            let results = JSON(parseJSON: resultString)["results"]
            self.memories = results.arrayValue.map { result -> Memory in
                let memory = Memory(id: "\(result["id"].stringValue)")
                memory.creatorUsername = "" // TODO: This should be done after API merge
                memory.title = result["title"].stringValue
                memory.contents = result["text"].stringValue
                return memory
            }
        }
    }
    
    static var sample: MemoriesViewModel {
        let viewModel = MemoriesViewModel()
        viewModel.isSample = true
        viewModel.memories = [Memory.sample]
        return viewModel
    }
}
