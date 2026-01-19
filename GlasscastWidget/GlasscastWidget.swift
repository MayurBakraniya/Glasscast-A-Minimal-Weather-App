//
//  GlasscastWidget.swift
//  GlasscastWidget
//
//  Created by Mayur Bakraniya on 19/01/26.
//

import WidgetKit
import SwiftUI

struct GlasscastEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetWeatherSnapshot?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> GlasscastEntry {
        GlasscastEntry(
            date: Date(),
            snapshot: WidgetWeatherSnapshot(
                city: "London",
                temp: 22,
                conditionIcon: "01d",
                timestamp: Date()
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (GlasscastEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GlasscastEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh every 30 minutes
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadEntry() -> GlasscastEntry {
        print("📱 [Widget Provider] Loading entry...")
        let snap = WidgetWeatherStore.load()
        if let s = snap {
            print("✅ [Widget Provider] Entry loaded with snapshot: \(s.city)")
        } else {
            print("⚠️ [Widget Provider] Entry loaded without snapshot (placeholder)")
        }
        return GlasscastEntry(date: Date(), snapshot: snap)
    }
}

struct GlasscastWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Fallback gradient (duplicate of app background)
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.18),
                    Color(red: 0.15, green: 0.10, blue: 0.25),
                    Color(red: 0.20, green: 0.12, blue: 0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            if let s = entry.snapshot {
                VStack(alignment: .leading, spacing: 6) {
                    Text(s.city)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("\(Int(s.temp.rounded()))°")
                        .font(.system(size: 40, weight: .thin))
                        .foregroundColor(.white)

                    Spacer()

                    Text("Updated \(entry.date.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            } else {
                VStack(spacing: 4) {
                    Text("Glasscast")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Open the app to load weather")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            }
        }
    }
}

struct GlasscastWidget: Widget {
    let kind: String = "GlasscastWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GlasscastWidgetEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Current Weather")
        .description("Shows the current weather from Glasscast.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
