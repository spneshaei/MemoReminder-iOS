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
    
    func loadMemories() async {
        guard !isSample else { return }
    }
    
    static var sample: MemoriesViewModel {
        let viewModel = MemoriesViewModel()
        viewModel.isSample = true
        viewModel.memories = [Memory.sample]
        return viewModel
    }
}
