//
//  AddReminderView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI
import UserNotifications

struct AddReminderView: View {
    @Environment(\.presentationMode) var mode
    @ObservedObject var remindersViewModel: RemindersViewModel
    
    @State var text = ""
    @State var date = Date().addingTimeInterval(3600)
    
    func addNotification() {
        // https://stackoverflow.com/questions/44632876/swift-3-how-to-set-up-local-notification-at-specific-date
        let content = UNMutableNotificationContent()
        content.title = "Scheduled Reminder"
        content.body = text
        content.categoryIdentifier = "MemoReminderReminders"
        content.sound = UNNotificationSound.default
        content.badge = 1
        let dateComponents = Calendar.current.dateComponents(Set(arrayLiteral: Calendar.Component.year, Calendar.Component.month, Calendar.Component.day), from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "com.spneshaei.MemoReminders.notifications", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if let error = error {
                print(error)
            } else {
                print("Notification successful!")
                mode.wrappedValue.dismiss()
            }
        })
    }
    
    func addReminder() {
        let reminder = Reminder()
        reminder.text = text
        reminder.date = date
        remindersViewModel.reminders.append(reminder)
        remindersViewModel.reminders.sort { $0.date > $1.date }
        addNotification()
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
