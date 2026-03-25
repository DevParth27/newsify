import 'package:hive/hive.dart';

import '../../models/article_model.dart';

class NewsLocalDataSource {
  NewsLocalDataSource(this._box);

  static const String boxName = 'favorites_box';

  final Box<ArticleModel> _box;

  static void registerAdapter() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ArticleModelAdapter());
    }
  }

  Future<void> saveFavorite(ArticleModel article) async {
    final key = article.url ?? article.title;
    await _box.put(key, article);
  }

  Future<void> removeFavorite(String url) async {
    await _box.delete(url);
  }

  List<ArticleModel> getFavorites() {
    return _box.values.toList();
  }
}
