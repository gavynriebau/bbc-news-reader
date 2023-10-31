class TabDetail {
  final String tabTitle;
  final String rssUrl;

  const TabDetail({required this.tabTitle, required this.rssUrl});
}

const tabDetails = [
  TabDetail(
      tabTitle: "Top Stories", rssUrl: "http://feeds.bbci.co.uk/news/rss.xml"),
  TabDetail(
      tabTitle: "Tech",
      rssUrl: "http://feeds.bbci.co.uk/news/technology/rss.xml"),
  TabDetail(
      tabTitle: "World", rssUrl: "http://feeds.bbci.co.uk/news/world/rss.xml"),
  TabDetail(
      tabTitle: "Science",
      rssUrl: "http://feeds.bbci.co.uk/news/science_and_environment/rss.xml"),
  TabDetail(
      tabTitle: "Australia",
      rssUrl: "https://feeds.bbci.co.uk/news/world/australia/rss.xml")
];
