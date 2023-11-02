import '../article.dart';

abstract class ArticleFetcher {
  Future<List<Article>> fetchFromRssFeed(String rssUrl);
}
