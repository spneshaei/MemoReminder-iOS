//
//  MainAppViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/13/21.
//

import SwiftUI

class MainAppViewModel: ObservableObject {
    enum CurrentView {
        case login, signUp, mainTabView
    }
    
    @Published var currentView: CurrentView = .login
    
    static var sample: MainAppViewModel {
        MainAppViewModel()
    }
}
