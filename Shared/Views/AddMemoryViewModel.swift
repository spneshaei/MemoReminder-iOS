//
//  AddMemoryViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/19/21.
//

import SwiftUI

class AddMemoryViewModel: ObservableObject {
    var isSample = false
    
    @Published var mentionedUsers: [User] = []
    
    static var sample: AddMemoryViewModel {
        let viewModel = AddMemoryViewModel()
        viewModel.mentionedUsers = [User.sample]
        return viewModel
    }
}
