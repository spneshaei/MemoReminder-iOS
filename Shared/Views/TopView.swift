//
//  TopView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/13/21.
//

import SwiftUI

struct TopView: View {
    @EnvironmentObject var viewModel: MainAppViewModel
    
    var body: some View {
        switch viewModel.currentView {
        case .login:
            LoginView()
                .erasedToAnyView()
        case .signUp:
            SignUpView()
                .erasedToAnyView()
        case .mainTabView:
            MainTabView()
                .erasedToAnyView()
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
            .environmentObject(MainAppViewModel.sample)
    }
}
