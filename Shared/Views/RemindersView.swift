//
//  NotificationRemindersView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI

struct RemindersView: View {
    @StateObject var viewModel = RemindersViewModel()
    
    @State var isNavigationToAddReminderViewActive = false
    
    func deleteReminders(at offsets: IndexSet) {
        viewModel.reminders.remove(atOffsets: offsets)
    }
    
    var body: some View {
        List {
            if !viewModel.reminders.isEmpty {
                ForEach(viewModel.reminders) { reminder in
                    NotificationReminderCell(reminder: reminder)
                        .opacity(reminder.date < Date() ? 0.75 : 1)
                        .listRowSeparator(.hidden)
                }
                .onDelete(perform: deleteReminders)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationBarTitle("Reminders")
        .navigationBarItems(trailing: HStack(spacing: 20) {
            NavigationLink(destination: AddReminderView(remindersViewModel: viewModel), isActive: $isNavigationToAddReminderViewActive) {
                Button(action: {
                    isNavigationToAddReminderViewActive = true
                }) {
                    Image(systemName: "plus")
                }
            }
            EditButton()
        })
    }
}

struct NotificationSchedulingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RemindersView()
                .preferredColorScheme(.dark)
        }
    }
}
