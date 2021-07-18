//
//  TagsViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/17/21.
//

import SwiftUI

class TagsViewModel: ObservableObject {
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    var isSample = false
    
    @Published var selectedTags: [Tag] = []

    @Published var allTags: [Tag] {
        didSet {
            defaults.set(try? encoder.encode(allTags), forKey: "TagsViewModel_allTags")
        }
    }
    
    var unselectedTags: [Tag] {
        allTags.filter {tag in !selectedTags.contains { selectedTag in tag.id == selectedTag.id } }
    }
    
    init() {
        if let allTags = try? decoder.decode([Tag].self, from: defaults.data(forKey: "TagsViewModel_allTags") ?? Data()) {
            self.allTags = allTags
        } else {
            self.allTags = []
        }
    }
    
    func loadTags(globalData: GlobalData) async throws {
        guard !isSample else { return }
        let resultString = try await Rester.rest(endPoint: "tag/?token=\(globalData.token)", body: "", method: .get)
        main {
            let results = JSON(parseJSON: resultString)["results"]
            self.allTags = results.arrayValue.map { result -> Tag in
                let tag = Tag(id: result["id"].intValue)
                tag.name = result["name"].stringValue
                tag.color = result["color"].stringValue.deletingPrefix("#")
                return tag
            }
        }
    }
    
    static var sample: TagsViewModel {
        let viewModel = TagsViewModel()
        viewModel.selectedTags = [Tag.sample]
        viewModel.allTags = [Tag.sample]
        return viewModel
    }
}
