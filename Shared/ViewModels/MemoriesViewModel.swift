//
//  MemoriesViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

class MemoriesViewModel: ObservableObject {
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    var isSample = false
    
    @Published var memories: [Memory] {
        didSet {
            defaults.set(try? encoder.encode(memories), forKey: "MemoriesViewModel_memories")
        }
    }
    
    @Published var searchPredicate = ""
    
    init() {
        if let memories = try? decoder.decode([Memory].self, from: defaults.data(forKey: "MemoriesViewModel_memories") ?? Data()) {
            self.memories = memories
        } else {
            self.memories = []
        }
    }
    
    var filteredMemories: [Memory] {
        searchPredicate.isEmpty ? memories : memories.filter { $0.title.lowercased().contains(searchPredicate.lowercased())
            || $0.contents.lowercased().contains(searchPredicate.lowercased()) || $0.creatorUsername.lowercased().contains(searchPredicate.lowercased()) }
    }
    
    var aYearAgoMemories: [Memory] {
        let exactlyAYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(timeIntervalSince1970: 1)
        let aWeekBefore = Calendar.current.date(byAdding: .day, value: -7, to: exactlyAYearAgo) ?? Date(timeIntervalSince1970: 1)
        let aWeekAfter = Calendar.current.date(byAdding: .day, value: 7, to: exactlyAYearAgo) ?? Date(timeIntervalSince1970: 1)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return memories.filter {
            let date = dateFormatter.date(from: $0.createdDate.components(separatedBy: "T").first ?? "") ?? Date()
            return aWeekBefore <= date && date <= aWeekAfter
        }
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
    
    static var sample: MemoriesViewModel {
        let viewModel = MemoriesViewModel()
        viewModel.isSample = true
        viewModel.memories = [Memory.sample]
        return viewModel
    }
}
