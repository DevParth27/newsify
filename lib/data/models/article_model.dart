import 'package:hive/hive.dart';

import '../../domain/entities/article.dart';

class ArticleModel {
  final String title;
  final String? description;
  final String? url;
  final String? imageUrl;
  final String? source;
  final DateTime? publishedAt;
  final String? category;

  const ArticleModel({
    required this.title,
    this.description,
    this.url,
    this.imageUrl,
    this.source,
    this.publishedAt,
    this.category,
  });

  factory ArticleModel.fromJson(
    Map<String, dynamic> json, {
    String? category,
  }) {
    final src = json['source'];
    String? sourceName;
    if (src is Map<String, dynamic>) {
      sourceName = src['name'] as String?;
    }
    DateTime? pubAt;
    final published = json['publishedAt'];
    if (published is String) {
      pubAt = DateTime.tryParse(published);
    }
    return ArticleModel(
      title: (json['title'] as String?) ?? '',
      description: json['description'] as String?,
      url: json['url'] as String?,
      imageUrl: json['urlToImage'] as String?,
      source: sourceName,
      publishedAt: pubAt,
      category: category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': imageUrl,
      'source': {'name': source},
      'publishedAt': publishedAt?.toIso8601String(),
      'category': category,
    };
  }

  Article toEntity() {
    return Article(
      title: title,
      description: description,
      url: url,
      imageUrl: imageUrl,
      source: source,
      publishedAt: publishedAt,
      category: category,
    );
  }

  factory ArticleModel.fromEntity(Article article) {
    return ArticleModel(
      title: article.title,
      description: article.description,
      url: article.url,
      imageUrl: article.imageUrl,
      source: article.source,
      publishedAt: article.publishedAt,
      category: article.category,
    );
  }
}

class ArticleModelAdapter extends TypeAdapter<ArticleModel> {
  @override
  final int typeId = 0;

  @override
  ArticleModel read(BinaryReader reader) {
    return ArticleModel(
      title: reader.read() as String,
      description: reader.read() as String?,
      url: reader.read() as String?,
      imageUrl: reader.read() as String?,
      source: reader.read() as String?,
      publishedAt: reader.read() as DateTime?,
      category: reader.read() as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ArticleModel obj) {
    writer.write(obj.title);
    writer.write(obj.description);
    writer.write(obj.url);
    writer.write(obj.imageUrl);
    writer.write(obj.source);
    writer.write(obj.publishedAt);
    writer.write(obj.category);
  }
}
