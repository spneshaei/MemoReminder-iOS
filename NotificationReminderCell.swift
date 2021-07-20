//
//  NotificationReminderCell.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI

struct NotificationReminderCell: View {
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool { colorScheme == .dark }
    
    var reminder: Reminder
    
    var body: some View {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                Text(reminder.text)
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundColor(.black)
                Text(formatter.string(from: reminder.date))
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 70/255, green: 70/255, blue: 70/255))
            }.padding(20)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(isDarkMode ? Color.orange : Color(red: 247/255, green: 207/255, blue: 71/255))
        .opacity(0.8)
        .modifier(MemoryCardModifier())
        .padding(.all, 10)
        .listRowSeparator(.hidden)
    }
}

struct NotificationReminderCell_Previews: PreviewProvider {
    static var previews: some View {
        NotificationReminderCell(reminder: .sample)
    }
}
