//
//  URLImage.swift
//  HeadlinesWidgetExtension
//
//  Created by Lisandro on 13/09/2020.
//

import SwiftUI

struct URLImage: View {
    var url: String?

    var body: some View {
        Group {
            if let urlString = url,
                  let url = URL(string: urlString),
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
            } else {
                Rectangle()
                    .background(Color.clear)
            }
        }
    }
}

struct URLImage_Previews: PreviewProvider {
    static var previews: some View {
        URLImage(url: "https://static01.nyt.com/images/2020/09/13/reader-center/13fires-briefing-ore1/13fires-briefing-ore1-facebookJumbo.jpg")
    }
}
