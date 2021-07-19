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
    @Published var isDateSelected = false
    @Published var showOnlyMyOwnMemories = false
    
    var hasFilter: Bool {
        return isDateSelected || showOnlyMyOwnMemories
    }
    
    @Published var selectedDate = Date()
    
    init() {
        if let memories = try? decoder.decode([Memory].self, from: defaults.data(forKey: "MemoriesViewModel_memories") ?? Data()) {
            self.memories = memories
        } else {
            self.memories = []
        }
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool { // https://www.zerotoappstore.com/how-to-check-if-two-dates-are-from-the-same-day-swift.html
//        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
//        if diff.day == 0 {
//            return true
//        } else {
//            return false
//        }
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    func filteredMemories(globalData: GlobalData) -> [Memory] {
        var filteredMemoriesWithSearchPredicate = searchPredicate.isEmpty ? memories : memories.filter { $0.title.lowercased().contains(searchPredicate.lowercased())
            || $0.contents.lowercased().contains(searchPredicate.lowercased()) || $0.creatorUsername.lowercased().contains(searchPredicate.lowercased()) }
        if showOnlyMyOwnMemories {
            filteredMemoriesWithSearchPredicate = filteredMemoriesWithSearchPredicate.filter { $0.creatorUserID == globalData.userID }
        }
        if isDateSelected {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            return filteredMemoriesWithSearchPredicate.filter { isSameDay(date1: selectedDate, date2: dateFormatter.date(from: $0.createdDate.components(separatedBy: "T").first ?? "") ?? Date(timeIntervalSince1970: 1) ) }.reversed()
        } else {
            return filteredMemoriesWithSearchPredicate.reversed()
        }
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
