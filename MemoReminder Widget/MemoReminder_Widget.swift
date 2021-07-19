//
//  MemoReminder_Widget.swift
//  MemoReminder Widget
//
//  Created by Seyyed Parsa Neshaei on 7/19/21.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 1000 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct MemoReminder_WidgetEntryView : View {
    var entry: Provider.Entry
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func printer(_ string: String) -> EmptyView {
        print(string)
        return EmptyView()
    }

    var body: some View {
//        Text(entry.date, style: .time)
        printer("stage1")
        if let defaults = UserDefaults(suiteName: "group.com.spneshaei.MemoReminder") {
            printer("stage2")
            if let topMemories = try? decoder.decode([Memory].self, from: defaults.data(forKey: "HomeViewModel_topMemories") ?? Data()) {
                printer("stage3")
                if let hottestMemory = topMemories.first {
                    printer("stage4")
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(hottestMemory.createdDate).font(.caption2)
                            Text(hottestMemory.title).font(.title3).bold()
                            Spacer()
                            Text(hottestMemory.creatorFirstName).font(.footnote)
                        }
                        .padding(.vertical)
                        .padding(.horizontal)
                        Spacer()
                    }
                    .background(Color.orange)
                } else {
                    Text("Login to continue")
                }
            } else {
                Text("Login to continue")
            }
        } else {
            Text("Login to continue")
        }
    }
}

@main
struct MemoReminder_Widget: Widget {
    let kind: String = "MemoReminder_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MemoReminder_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MemoReminder")
        .description("See the hottest memory")
    }
}

struct MemoReminder_Widget_Previews: PreviewProvider {
    static var previews: some View {
        MemoReminder_WidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
