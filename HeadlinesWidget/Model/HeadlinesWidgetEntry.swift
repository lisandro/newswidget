//
//  HeadlinesWidgetEntry.swift
//  HeadlinesWidgetExtension
//
//  Created by Lisandro on 13/09/2020.
//

import WidgetKit

struct HeadlinesWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let articles: [Article]
    let country: String
}
