import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String title;
  final String? description;
  final String? url;
  final String? imageUrl;
  final String? source;
  final DateTime? publishedAt;
  final String? category;

  const Article({
    required this.title,
    this.description,
    this.url,
    this.imageUrl,
    this.source,
    this.publishedAt,
    this.category,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        url,
        imageUrl,
        source,
        publishedAt,
        category,
      ];
}
