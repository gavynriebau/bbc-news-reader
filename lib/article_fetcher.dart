import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'dart:convert';


class Article {
  final String title;

  Article(this.title);
}

class ArticleFetcher {
  Future<List<Article>> fetch() async {
    developer.log("Fetching articles...");

    final articles = <Article>[];

    final response = await http.get(Uri.parse('https://push.api.bbci.co.uk/batch?t=%2Fdata%2Fbbc-morph-%7Blx-commentary-data-paged%2Fabout%2Fe745fc56-51bf-46b5-9b74-f0f529ea4d8e%2FisUk%2Ffalse%2Flimit%2F20%2FnitroKey%2Flx-nitro%2FpageNumber%2F0%2Fversion%2F1.5.6%2Clx-commentary-data-paged%2Fabout%2Fe745fc56-51bf-46b5-9b74-f0f529ea4d8e%2FisUk%2Ffalse%2Flimit%2F20%2FnitroKey%2Flx-nitro%2FpageNumber%2F1%2Fversion%2F1.5.6%2Clx-commentary-data-paged%2Fabout%2Fe745fc56-51bf-46b5-9b74-f0f529ea4d8e%2FisUk%2Ffalse%2Flimit%2F20%2FnitroKey%2Flx-nitro%2FpageNumber%2F50%2Fversion%2F1.5.6%7D?timeout=5'));

    final statusCode = response.statusCode;
    developer.log("response.statusCode = $statusCode");

    if (statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;  
      final payload = json['payload'] as List<dynamic>;

      for (var item in payload) {
        final body = item['body'] as Map<String, dynamic>;
        final results = body['results'] as List<dynamic>;
        for (var result in results) {
          final title = result['title'] as String;
          final article = Article(title);
          articles.add(article);
        }
      }

      
    }

    return articles;
  }
}

