//
//  HeadlinesWidget.swift
//  HeadlinesWidget
//
//  Created by Lisandro on 13/09/2020.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct HeadlinesWidget: Widget {
    let kind: String = "HeadlinesWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()) { entry in
            HeadlinesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Top Stories")
        .description("See the latest top stories of Argentina and the United States")
    }
}
