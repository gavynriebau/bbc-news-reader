class Article {
  final String title;
  final String summary;
  final String detailsUrl;
  final String publicationDate;

  Article(
      {required this.title,
      required this.summary,
      required this.detailsUrl,
      required this.publicationDate});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'detailsUrl': detailsUrl,
      'publicationDate': publicationDate
    };
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String;
    final summary = json['summary'] as String;
    final detailsUrl = json['detailsUrl'] as String;
    final publicationDate = json['publicationDate'] as String;

    return Article(
        title: title,
        summary: summary,
        detailsUrl: detailsUrl,
        publicationDate: publicationDate);
  }
}
