//
//  HeadlinesWidgetEntryView.swift
//  HeadlinesWidgetExtension
//
//  Created by Lisandro on 13/09/2020.
//

import SwiftUI
import WidgetKit

struct HeadlinesWidgetEntryView : View {
    var entry: HeadlinesWidgetEntry
    @Environment(\.widgetFamily) var family: WidgetFamily

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall: SmallWidgetView(entry: entry)
        case .systemLarge: MediumLargeWidgetView(entry: entry, articlesCount: 5)
        case .systemMedium: MediumLargeWidgetView(entry: entry, articlesCount: 2)
        default: Text(entry.date, style: .time)
        }
    }
}

struct HeadlinesWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HeadlinesWidgetEntryView(entry: HeadlinesWidgetEntry(date: Date(), configuration: ConfigurationIntent(), articles: testArticles, country: "🇺🇸"))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            HeadlinesWidgetEntryView(entry: HeadlinesWidgetEntry(date: Date(), configuration: ConfigurationIntent(), articles: testArticles, country: "🇺🇸"))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            HeadlinesWidgetEntryView(entry: HeadlinesWidgetEntry(date: Date(), configuration: ConfigurationIntent(), articles: testArticles, country: "🇺🇸"))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}


let testArticles = [
    Article(title: "What does the PS5 HD Camera accessory do, and should you buy it? - TechRadar", url: "https://www.techradar.com/news/what-does-the-ps5-hd-camera-accessory-do-and-should-you-buy-it", urlToImage: "https://cdn.mos.cms.futurecdn.net/jKnbj56KmDyfnKDF3sasm6-1200-80.jpg"),
    Article(title: "Hundreds mourn Ruth Bader Ginsburg in vigil outside Supreme Court - NBC News", url: "https://www.nbcnews.com/politics/supreme-court/hundreds-mourn-ruth-bader-ginsburg-vigil-outside-supreme-court-n1240531", urlToImage: "https://media1.s-nbcnews.com/j/newscms/2020_38/3413299/200918-supreme-court-rgb-reaction-ew-931p_ab924360afb4e03716719f2be090f772.nbcnews-fp-1200-630.jpg"),
    Article(title: "3 Tech Stocks to Buy in the Market Correction - Motley Fool", url: "https://www.fool.com/investing/2020/09/19/3-tech-stocks-to-buy-in-the-market-correction/", urlToImage: "https://g.foolcdn.com/editorial/images/592052/gettyimages-1195117847.jpg"),
    Article(title: "NBA playoffs - How the Celtics get back into the East finals - ESPN", url: "https://www.espn.com/nba/story/_/page/zachlowe29911273/nba-playoffs-how-celtics-get-back-east-finals", urlToImage: "https://a.espncdn.com/combiner/i?img=%2Fphoto%2F2020%2F0918%2Fr747454_1296x729_16%2D9.jpg"),
    Article(title: "Trump accuses Dems, media of 'denigrating' potential coronavirus vaccine - Fox News", url: "https://www.foxnews.com/politics/trump-coronavirus-vaccine-mark-levin-life-liberty", urlToImage: "https://cf-images.us-east-1.prod.boltdns.net/v1/static/694940094001/d310fa68-d209-42ac-bb06-7bcdd6342139/efff3815-c6ee-4d20-bfd8-d4870b781282/1280x720/match/image.jpg"),
]

