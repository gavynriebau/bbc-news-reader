class TabDetail {
  final String title;
  final String rssUrl;

  const TabDetail({required this.title, required this.rssUrl});
}

const tabDetails = [
  TabDetail(
      title: "Top Stories", rssUrl: "http://feeds.bbci.co.uk/news/rss.xml"),
  TabDetail(
      title: "Tech", rssUrl: "http://feeds.bbci.co.uk/news/technology/rss.xml"),
  TabDetail(
      title: "World", rssUrl: "http://feeds.bbci.co.uk/news/world/rss.xml"),
  TabDetail(
      title: "Science",
      rssUrl: "http://feeds.bbci.co.uk/news/science_and_environment/rss.xml"),
  TabDetail(
      title: "Australia",
      rssUrl: "https://feeds.bbci.co.uk/news/world/australia/rss.xml"),
  TabDetail(
      title: "Asia", rssUrl: "http://feeds.bbci.co.uk/news/world/asia/rss.xml"),
  TabDetail(
      title: "US & Canada",
      rssUrl: "http://feeds.bbci.co.uk/news/world/us_and_canada/rss.xml")
];
