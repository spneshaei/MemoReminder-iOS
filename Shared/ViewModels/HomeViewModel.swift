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
    
    static var sample: HomeViewModel {
        let viewModel = HomeViewModel()
        viewModel.isSample = true
        viewModel.topMemories = [Memory.sample, Memory.sample]
        viewModel.friendsMemories = [Memory.sample, Memory.sample]
        return viewModel
    }
}
