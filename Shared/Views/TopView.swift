//
//  TopView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/13/21.
//

import SwiftUI

struct TopView: View {
    @ObservedObject var viewModel: MainAppViewModel
    
    var body: some View {
        switch viewModel.currentView {
        case .login:
            LoginView(mainAppViewModel: viewModel)
                .erasedToAnyView()
        case .signUp:
            SignUpView(mainAppViewModel: viewModel)
                .erasedToAnyView()
        case .mainTabView:
            MainTabView()
                .erasedToAnyView()
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView(viewModel: MainAppViewModel.sample)
    }
}
