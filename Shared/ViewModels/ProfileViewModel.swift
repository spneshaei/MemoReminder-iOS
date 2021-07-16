//
//  ProfileViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    var isSample = false
    @Published var myMemories: [Memory] = []
    @Published var user = User()
    @Published var followRequests: [User] = []
    
    func loadMyMemories() async {
        guard !isSample else { return }
    }
    
    func loadUser() async {
        guard !isSample else { return }
    }
    
    func loadFollowRequests() async {
        guard !isSample else { return }
    }
    
    static var sample: ProfileViewModel {
        let viewModel = ProfileViewModel()
        viewModel.isSample = true
        viewModel.myMemories = [Memory.sample]
        viewModel.followRequests = [User.sample]
        viewModel.user = User.sample
        return viewModel
    }
}
