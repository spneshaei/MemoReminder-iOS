//
//  NotificationRemindersView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI
import UserNotifications

struct RemindersView: View {
    @Environment(\.presentationMode) var mode
    @StateObject var viewModel = RemindersViewModel()
    
    @State var isNavigationToAddReminderViewActive = false
    @State var isDeleteSheetPresented = false
    @State var shouldShowNotificationsAccessDeniedAlert = false
    
    func deleteReminders(at offsets: IndexSet) {
        withAnimation { viewModel.reminders.remove(atOffsets: offsets) }
    }
    
    var body: some View {
        List {
            if !viewModel.reminders.isEmpty {
                ForEach(viewModel.reminders) { reminder in
                    NotificationReminderCell(reminder: reminder)
                        .opacity(reminder.date < Date() ? 0.75 : 1)
                        .listRowSeparator(.hidden)
                        .contextMenu {
                            Button {
                                withAnimation { viewModel.reminders.removeAll { $0.id == reminder.id } }
                            } label: {
                                Label("Remove Reminder", systemImage: "trash")
                            }
                        }
                }
                .onDelete(perform: deleteReminders)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationBarTitle("Reminders")
        .confirmationDialog("Are you sure you want to delete all previously fired reminders?", isPresented: $isDeleteSheetPresented, titleVisibility: .visible) {
            Button("Yes", role: .destructive) {
                viewModel.reminders = []
            }
            Button("No", role: .cancel) { }
        }
        .navigationBarItems(trailing: HStack(spacing: 20) {
            Button(action: {
                isDeleteSheetPresented = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .accessibility(hint: Text("Delete all fired reminders"))
            }
            
            NavigationLink(destination: AddReminderView(remindersViewModel: viewModel), isActive: $isNavigationToAddReminderViewActive) {
                Button(action: {
                    isNavigationToAddReminderViewActive = true
                }) {
                    Image(systemName: "plus")
                }
            }
            
            EditButton()
        })
        .onAppear {
            // https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let _ = error {
                    main { shouldShowNotificationsAccessDeniedAlert = true }
                }
            }
        }
        .alert("You've previously denied the app's ability to send you notifications. Please grant the app access to send you notifications by opening the Settings app.", isPresented: $shouldShowNotificationsAccessDeniedAlert) {
            Button("OK", role: .cancel) {
                self.mode.wrappedValue.dismiss()
            }
        }
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
