
class TabDetail {
  final String tabTitle;
  final String rssUrl;

  const TabDetail({required this.tabTitle, required this.rssUrl});
}

const tabDetails = [
  TabDetail(
    tabTitle: "Top Stories",
    rssUrl: "http://feeds.bbci.co.uk/news/rss.xml"
  ),
  TabDetail(
    tabTitle: "Tech",
    rssUrl: "http://feeds.bbci.co.uk/news/technology/rss.xml"
  )
];

