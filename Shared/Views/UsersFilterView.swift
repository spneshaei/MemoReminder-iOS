//
//  UsersFilterView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/19/21.
//

import SwiftUI

struct UsersFilterView: View {
    @ObservedObject var searchViewModel: UsersViewModel
    
    var body: some View {
        Form {
            Toggle("Show only the users I follow", isOn: $searchViewModel.showOnlyTheUsersIFollow)
            Toggle("Show only the users in my contacts", isOn: $searchViewModel.showOnlyTheUsersInMyContacts)
        }
        .navigationBarTitle("Filter Users")
    }
}

struct UsersFilterView_Previews: PreviewProvider {
    static var previews: some View {
        UsersFilterView(searchViewModel: .sample)
    }
}
