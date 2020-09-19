//
//  MediumLargeWidgetView.swift
//  GoodNews
//
//  Created by Lisandro on 13/09/2020.
//

import SwiftUI
import WidgetKit

struct MediumLargeWidgetView: View {
    var entry: HeadlinesWidgetEntry
    var articlesCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 7.0) {
            HStack {
                widgetHeaderView
                Spacer()
                Text(entry.country)
                    .padding([.top, .trailing])
            }
            ForEach(0..<articlesCount) { index in
                if entry.articles.count > index,
                    let item = entry.articles[index],
                    let url = URL(string: item.url) {
                    Link(destination: url) {
                        ArticleRow(item: item)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 15.0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    let widgetHeaderView: some View = Text("🔥 TOP STORIES")
        .font(.headline)
        .foregroundColor(Color.storyTitle)
        .padding(.top)
}

struct MediumLargeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MediumLargeWidgetView(entry: HeadlinesWidgetEntry(date: Date(), configuration: ConfigurationIntent(), articles: testArticles, country: "🇺🇸"), articlesCount: 5)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            MediumLargeWidgetView(entry: HeadlinesWidgetEntry(date: Date(), configuration: ConfigurationIntent(), articles: testArticles, country: "🇺🇸"), articlesCount: 2)
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            MediumLargeWidgetView(entry: HeadlinesWidgetEntry(date: Date(), configuration: ConfigurationIntent(), articles: testArticles, country: "🇺🇸"), articlesCount: 4)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")

            MediumLargeWidgetView(entry: HeadlinesWidgetEntry(date: Date(), configuration: ConfigurationIntent(), articles: testArticles, country: "🇺🇸"), articlesCount: 2)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
