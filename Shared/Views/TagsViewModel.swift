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
    
    init() {
        if let allTags = try? decoder.decode([Tag].self, from: defaults.data(forKey: "TagsViewModel_allTags") ?? Data()) {
            self.allTags = allTags
        } else {
            self.allTags = []
        }
    }
    
    static var sample: TagsViewModel {
        let viewModel = TagsViewModel()
        viewModel.selectedTags = []
        viewModel.allTags = [Tag.sample]
        return viewModel
    }
}
