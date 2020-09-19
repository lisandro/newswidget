//
//  HeadlinesWidgetProvider.swift
//  HeadlinesWidgetExtension
//
//  Created by Lisandro on 13/09/2020.
//

import WidgetKit
import Intents

struct Provider: IntentTimelineProvider {
    typealias Entry = HeadlinesWidgetEntry
    
    func placeholder(in context: Context) -> Entry {
        HeadlinesWidgetEntry(date: Date(), configuration: ConfigurationIntent(), articles: testArticles, country: "")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        var countryCode = "🇦🇷"
        switch configuration.country {
        case .ar:
            countryCode = "🇦🇷"
        case .us:
            countryCode = "🇺🇸"
        case .unknown:
            break
        }
        let entry = HeadlinesWidgetEntry(date: Date(), configuration: configuration, articles: testArticles, country: countryCode)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Generate a timeline consisting of the latest news now and setting a update policy after 15 minutes
        let currentDate = Date()
        // The next date when the widget should reload the view with a new timeline
        let nextWidgetUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        // The date of the only widget entry that will be part of the timeline.
        let currentHeadlinesEntry = HeadlinesWidgetEntry(date: currentDate, configuration: configuration, articles: [], country: "")
        // Timeline instance without articles in case that the retrieve from the network fails we return no stories
        let timeline = Timeline(entries: [currentHeadlinesEntry], policy: .after(nextWidgetUpdateDate))

        // Retrieve data from the network
        // Use country code selected by the user to retrieve the news
        var countryCode = "ar"
        var countryFlag = "🇦🇷"
        switch configuration.country {
        case .ar:
            countryCode = "ar"
            countryFlag = "🇦🇷"
        case .us:
            countryCode = "us"
            countryFlag = "🇺🇸"
        case .unknown:
            break
        }

        let newsApiKey = ""
        guard let headlinesUrl = URL(string: "https://newsapi.org/v2/top-headlines?country=\(countryCode)&apiKey=\(newsApiKey)") else {
            return completion(timeline)
        }
        let topHeadlinesTask = URLSession.shared.topHeadlinesTask(with: headlinesUrl) { topHeadlines, response, error in
            if let topHeadlines = topHeadlines {
                let entry = HeadlinesWidgetEntry(date: nextWidgetUpdateDate, configuration: configuration, articles: topHeadlines.articles, country: countryFlag)
                completion(Timeline(entries: [entry], policy: .after(nextWidgetUpdateDate)))
            } else {
                completion(timeline)
            }
        }
        topHeadlinesTask.resume()
    }
}
