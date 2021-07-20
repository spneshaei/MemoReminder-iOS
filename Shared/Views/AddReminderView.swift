//
//  AddReminderView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI

struct AddReminderView: View {
    @ObservedObject var remindersViewModel: RemindersViewModel
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct AddReminderView_Previews: PreviewProvider {
    static var previews: some View {
        AddReminderView(remindersViewModel: .sample)
    }
}
