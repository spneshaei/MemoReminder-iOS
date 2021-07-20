//
//  AddReminderView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI

struct AddReminderView: View {
    @Environment(\.presentationMode) var mode
    @ObservedObject var remindersViewModel: RemindersViewModel
    
    @State var text = ""
    @State var date = Date().addingTimeInterval(3600)
    
    func addReminder() {
        let reminder = Reminder()
        reminder.text = text
        reminder.date = date
        remindersViewModel.reminders.append(reminder)
        remindersViewModel.reminders.sort { $0.date > $1.date }
        mode.wrappedValue.dismiss()
    }
    
    var body: some View {
        Form {
            Text("Text to be reminded about:")
                .listRowSeparator(.hidden)
            TextField("Add Memory...", text: $text)
                .textFieldStyle(.roundedBorder)
            DatePicker("Time", selection: $date)
                .listRowSeparator(.hidden)
            Text("You'll be notified at the selected time.")
        }
        .navigationBarTitle("Add Reminder")
        .navigationBarItems(trailing: Button(action: addReminder) {
            Text("Add").bold()
        })
    }
}

struct AddReminderView_Previews: PreviewProvider {
    static var previews: some View {
        AddReminderView(remindersViewModel: .sample)
    }
}
