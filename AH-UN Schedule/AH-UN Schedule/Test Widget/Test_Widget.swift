//
//  Test_Widget.swift
//  Test Widget
//
//  Created by ZoutigeWolf on 09/01/2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DataEntry {
        DataEntry(date: Date(), days: 10, hours: 62.25, salary: 809.25)
    }

    func getSnapshot(in context: Context, completion: @escaping (DataEntry) -> ()) {
        let entry = DataEntry(date: Date(), days: 10, hours: 62.25, salary: 809.25)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DataEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        Insights.getMonthlyStats(year: DateUtils.getDateComponent(Date.now, .year), month: DateUtils.getDateComponent(Date.now, .month)) { insight in
            if let i = insight {
                entries.append(DataEntry(date: Date.now, days: i.days, hours: i.hours, salary: i.salary))
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct DataEntry: TimelineEntry {
    var date: Date
    let days: Int
    let hours: Double
    let salary: Double
}

struct InfoView : View {
    let title: Text
    let value: Text
    var body: some View {
        VStack {
            title
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            
            value
                .font(.system(size: 16))
        }
    }
}

struct Test_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            HStack {
                InfoView(title: Text("Days"), value: Text(String(entry.days)))
                
                Spacer()
                
                InfoView(title: Text("Hours"), value: Text(String(entry.hours)))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            InfoView(title: Text("Salary"), value: Text(entry.salary, format: .currency(code: "EUR")))
        }
    }
}

struct Test_Widget: Widget {
    let kind: String = "Test_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                Test_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                Test_WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    Test_Widget()
} timeline: {
    DataEntry(date: Date(), days: 4, hours: 20.5, salary: 266.5)
}
