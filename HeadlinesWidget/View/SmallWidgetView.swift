//
//  SmallWidgetView.swift
//  GoodNews
//
//  Created by Lisandro on 13/09/2020.
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    var entry: HeadlinesWidgetEntry
    var body: some View {
        if let item = entry.articles.first(where: { URL(string: $0.url) != nil }) {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                VStack {
                    URLImage(url: item.urlToImage)
                        .scaledToFit()
                        .overlay(imageGradientOverlay, alignment: .bottom)
                    Spacer()
                }
                .background(Color.black)

                Text(item.title)
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(5)
                    .padding([.leading, .bottom, .trailing], 10.0)

            }
            .background(Color.widgetBackground)
            .widgetURL(URL(string: item.url)!)
        }
    }

    let imageGradientOverlay: some View = LinearGradient(
        gradient: Gradient(
            colors: [Color.black, Color.black.opacity(0.0)]),
        startPoint: .bottom,
        endPoint: .top)
        .frame(height: 48)
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetView(entry: HeadlinesWidgetEntry(date: Date(), configuration: ConfigurationIntent(), articles: testArticles, country: "🇺🇸"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
