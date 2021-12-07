# Create widgets in iOS 

In the WWDC20, Apple announced a disruptive new home screen experience in iOS14, one of them is the ability to add widgets on the iPhone/iPad home screen. 

iOS already supported some kind of widgets using the Today extension, so if you already have that extension in your app we can reuse some pieces of code like using a **shared group container** to store and read the data, however in terms of UI the new widget extension for is purely SwiftUI, and this is a interesting feature to start doing the first views using SwiftUI even if your app is developed with UIKit. I think of that Apple added this extension purely in SwiftUI to allow developers doing the first steps with SwiftUI in a productive app.

### Docs

First of all, I strongly recommend start reading and bookmarking Apple developer documentation about [WidgetKit](https://developer.apple.com/documentation/widgetkit), the [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/system-capabilities/widgets) for Widgets and if you have any question take a look Apple forum using [Widget topic](https://developer.apple.com/forums/tags/widgetkit)  . 

**ProTip**👨🏽‍💻: Eventhough there are a bunch of blog post like this, I recommend to read Apple docs first.

### Requisites 

- Xcode 12.0 or above
- Basic understanding of SwiftUI

### Let's get rolling

1. Open the Xcode project (or create a new one) and choose File > New > Target. 
2. Select Widget Extension, and click next.
3. Enter the product name of this new target.
4. Select the **Include Configuration Intent** checkbox to allow user customized config in the widget, otherwise if you do not want to allowing the user to configure the widget unselect
5. Click Finish

![](https://tva1.sinaimg.cn/large/007S8ZIlgy1giwhfnzjc3j314m0t20uh.jpg)

### Widget extension template walkthrough 

Xcode automatically creates a Swift file with five structs, to have the target group clean I recommend to extract each struct in different groups and files, for instance, I share an example here

- **Main**

  - `HeadlinesWidget` : Let's start reviewing the starting point of the widget, implementing `Widget` [protocol](https://developer.apple.com/documentation/swiftui/widget)  we return in the body a `WidgetConfiguration` specifying the provider, view, kind and depending of the type of widget can be a Static or Intent configuration. Let's continue with the data model of the widget 

- **Model**

  - `SimpleEntry` : This struct that implements `TimelineEntry` [protocol](https://developer.apple.com/documentation/widgetkit/timelineentry)  is the type that specifies the date and to display a widget and data needed in the content block of the configuration returned in `HeadlinesWidget`. The responsible of creating and returning this type is the **Provider**

- **ViewMode/Repository**

  - `Provider` : This struct that implements TimelineProvider protocol, if you uses a `IntentConfiguration` the provider has to implement **IntentTimelineProvider** [protocol](https://developer.apple.com/documentation/widgetkit/intenttimelineprovider) , in the case of `StaticConfiguration` **TimelineProvider** [protocol](https://developer.apple.com/documentation/widgetkit/timelineprovider) . In this example we will conform the `IntentTimelineProvider` to support user-customized values.

- **View**

  - `HeadlinesWidgetEntryView` : Finally we have a default SwiftUI View as part of the content block of the ``WidgetConfiguration`` defined at the beginning, 

    - `HeadlinesWidget_Previews`: The view also includes a preview, to see the content in Xcode. 
    

**ProTip**⚡️: I recommend to create a `Group` of preview for each [WidgetFamily](https://developer.apple.com/documentation/widgetkit/widgetfamily) that we want to support.

```swift
      Group {
                  HeadlinesWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                      .previewContext(WidgetPreviewContext(family: .systemSmall))
                  HeadlinesWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                      .previewContext(WidgetPreviewContext(family: .systemMedium))
                  HeadlinesWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                      .previewContext(WidgetPreviewContext(family: .systemLarge))
              }
```

![](https://tva1.sinaimg.cn/large/007S8ZIlgy1giwgovxoepj30u00y2761.jpg)

### Create the widget with the Latest News

##### Data model and API request task

Let's add a new struct to decode the latest stories using [NewsAPI.org](https://newsapi.org/) `https://newsapi.org/v2/top-headlines?country=us&apiKey=` . In our case we are only interested on the title and the thumbnail url of the news, so we'll create a new file `TopHeadlines.swift` 

```swift
import Foundation

// MARK: - TopHeadlines
struct TopHeadlines: Codable {
    let articles: [Article]
}

// MARK: - Article
struct Article: Codable {
    let title: String
    let url: String
    let urlToImage: String

    enum CodingKeys: String, CodingKey {
        case title
        case url, urlToImage
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - URLSession response handlers
extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func topHeadlinesTask(with url: URL, completionHandler: @escaping (TopHeadlines?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}
```

We have the model, and a `URLSession` task that would make the retrieve data easier for the purpose of this guide, in the case you would use more services of the API, I recommend to have a networking/API layer.

##### Widget Entry

We add to the existing Entry, an array of Article

```swift
struct HeadlinesWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let articles: [Article]
}
```

##### Widget Provider

Now we have to update our timeline provider to add an array of article in the `HeadlinesWidgetEntry`  , first of all we will update the **[placeholder](https://developer.apple.com/documentation/widgetkit/timelineprovider/placeholder(in:)-6ypjs)**

```swift
func placeholder(in context: Context) -> Entry {
        HeadlinesWidgetEntry(date: Date(), configuration: ConfigurationIntent(), articles: [])
    }
```

and the [**snapshot**](https://developer.apple.com/documentation/widgetkit/timelineprovider/getsnapshot(in:completion:)-4l50j)

```swift
func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = HeadlinesWidgetEntry(date: Date(), configuration: configuration, articles: [])
        completion(entry)
    }
```

finally we have the [**timeline**](https://developer.apple.com/documentation/widgetkit/intenttimelineprovider/gettimeline(for:in:completion:)-9oqa4)

```swift
func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Generate a timeline consisting of the latest news now and setting a update policy after 15 minutes
        let currentDate = Date()
        // The next date when the widget should reload the view with a new timeline
        let nextWidgetUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        // The date of the only widget entry that will be part of the timeline.
        let currentHeadlinesEntry = HeadlinesWidgetEntry(date: currentDate, configuration: configuration, articles: [])
        // Timeline instance without articles in case that the retrieve from the network fails we return no stories
        let timeline = Timeline(entries: [currentHeadlinesEntry], policy: .after(nextWidgetUpdateDate))

        // Retrieve data from the network
        // Use country code selected by the user to retrieve the news
        var countryCode = "ar"
        switch configuration.country {
        case .ar:
            countryCode = "ar"
        case .us:
            countryCode = "us"
        case .unknown:
            break
        }

        let newsApiKey = ""
        guard let headlinesUrl = URL(string: "https://newsapi.org/v2/top-headlines?country=\(countryCode)&apiKey=\(newsApiKey)") else {
            return completion(timeline)
        }
        let topHeadlinesTask = URLSession.shared.topHeadlinesTask(with: headlinesUrl) { topHeadlines, response, error in
            if let topHeadlines = topHeadlines {
                let entry = HeadlinesWidgetEntry(date: nextWidgetUpdateDate, configuration: configuration, articles: topHeadlines.articles)
                completion(Timeline(entries: [entry], policy: .after(nextWidgetUpdateDate)))
            } else {
                completion(timeline)
            }
        }
        topHeadlinesTask.resume()
    }
```

##### Widget View

The view of the widget is `HeadlinesWidgetEntryView` where we will use the environment variable `.widgetFamily` to return different views for each widget size:

```swift
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
```

For the `.systemSmall` widget we will create the `SmallWidgetView` and for `.systemLarge` and `.systemMedium` we will use the same view using a parameter to set the number of stories to show in each family:

###### SmallWidgetView

The small widget will show the most recent story of the response, using a `ZStack` we can put the image of the article in the background with a overlay gradient, and on top of the image the headline of the story. 

![](https://tva1.sinaimg.cn/large/007S8ZIlgy1giwgp5qxg6j30do0ayaay.jpg)

```swift
struct SmallWidgetView: View {
    var entry: HeadlinesWidgetEntry
    var body: some View {
        if let item = entry.articles.first {
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
            .background(Color.black)
        }
    }

    let imageGradientOverlay: some View = LinearGradient(
        gradient: Gradient(
            colors: [Color.black, Color.black.opacity(0.0)]),
        startPoint: .bottom,
        endPoint: .top)
        .frame(height: 48)
}
```

###### MediumLargeWidgetView

For the medium and large widget family we will reuse the same view, and just showing different amount of articles depending of the family. Using a **VStack** we'll render a list of stories and at the top of the widget a Text as widget header. I extracted each story view using `ArticleRow` item in a different struct

| Medium                                                       | Large                                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1giwgoy9g42j30kw0a2jsx.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1giwgp3amkfj30kw0lwtcj.jpg) |



```swift
struct MediumLargeWidgetView: View {
    var entry: HeadlinesWidgetEntry
    var articlesCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 7.0) {
            widgetHeaderView
            ForEach(0..<articlesCount) { index in
                if entry.articles.count > index,
                   let item = entry.articles[index] {
                    ArticleRow(item: item)
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
```

ArticleRow item:

```swift
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
```



### Open the app from the widget

The user can long press the widget if you support an IntentConfiguration to configure the widget with customized values, and the use can tap in the widget to open the app.  You can specify `.widgetURL` modifier with a deep link to the app, for example in the `.small` widget we can use that modifier because it's there is only one article, in case you have to support different deep links, you can use the `Link` view.

To add the url to the small widget we can add the `widgetURL` view modifier to the ZStack of the view

```swift
ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
  //...
}
.background(Color.black)
.widgetURL(URL(string: item.url)!)
```

Finally for each story of the medium and large widget we will wrap the ArticleRow in a `Link`

```swift
Link(destination: url) {
  ArticleRow(item: item)
}
```

**Challenge**💡: If you are interested on continuing this tutorial and I'll ask to handle the link tap in the app and create a pull request in this [project](https://github.com/lisandro/newswidget) to discuss and merge your solution to open the news url in the app using a webview

### Reviewing the widget in the Widget gallery

###### Light mode

|      |      |      |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1giwgozqaw5j30n01dsaes.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1giwhj10u07j30n01dsgos.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1giwgp7gxvej30n01ds0vf.jpg) |
|      |      |      |


###### Dark mode

|      |      |      |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1giwgp4vaqaj30n01ds42z.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1giwhj05c0qj30n01dsdis.jpg) | ![](https://tva1.sinaimg.cn/large/007S8ZIlgy1giwgp1ifhmj30n01ds76q.jpg) |
|      |      |      |


### Editing the widget

As a user I can long press in the widget and select the country from I wanna see the top stories, this allow the user to have two widget of the same app with different source.

![](https://tva1.sinaimg.cn/large/007S8ZIlgy1giwgox209ij30n01dswge.jpg)



### Where to go from here?

I recommend watch the [WWDC20](https://developer.apple.com/videos/play/wwdc2020/10034/) videos about designing and developing widgets, and something that it's important to mention in terms of eficienty of the widget, is read about [Keeping a Widget Up to Date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date) to understand how the widget refresh works and what you can do from the app using [`WidgetCenter`](https://developer.apple.com/documentation/widgetkit/widgetcenter) because Apple says that _widget receives a limited number of refreshes every day._ so choosing the correct refresh strategy for your widget is a game-changer.



The project is available in [Github](https://github.com/lisandro/newswidget), and I eager to see pull request contributing to this initial idea to share with the community.

**Ideas**: Show a empty state view when there is no articles to show, load url image using and ObservableObject, handle widgetURL in app opening a webview and more...! 🙌🏾


