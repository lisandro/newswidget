//
//  ArticleRow.swift
//  HeadlinesWidgetExtension
//
//  Created by Lisandro on 17/09/2020.
//

import SwiftUI
import WidgetKit

struct ArticleRow: View {
    let item: Article
    var body: some View {
        HStack(alignment: .top) {
            URLImage(url: item.urlToImage)
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                .frame(width: 75.0, height: 50.0)
            Text(item.title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color.storyTitle)
                .lineLimit(3)
            Spacer()
        }
    }
}

struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRow(item: articleRowPreviewArticle)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

let articleRowPreviewArticle = Article(title: "NBA playoffs - How the Celtics get back into the East finals - ESPN", url: "https://www.espn.com/nba/story/_/page/zachlowe29911273/nba-playoffs-how-celtics-get-back-east-finals", urlToImage: "https://a.espncdn.com/combiner/i?img=%2Fphoto%2F2020%2F0918%2Fr747454_1296x729_16%2D9.jpg")
