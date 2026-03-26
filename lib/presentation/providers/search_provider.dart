import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article.dart';
import '../../domain/usecases/news/search_articles.dart';
import 'news_feed_provider.dart';

final searchArticlesUseCaseProvider = Provider<SearchArticles>((ref) {
  return SearchArticles(ref.watch(newsRepositoryProvider));
});

class SearchNotifier extends StateNotifier<AsyncValue<List<Article>>> {
  SearchNotifier(this.ref) : super(const AsyncValue.data([]));

  final Ref ref;
  Timer? _timer;

  void search(String query) {
    _timer?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    _timer = Timer(const Duration(milliseconds: 300), () async {
      final result =
          await ref.read(searchArticlesUseCaseProvider).call(trimmed, 1);
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (articles) => state = AsyncValue.data(articles),
      );
    });
  }

  void clear() {
    _timer?.cancel();
    state = const AsyncValue.data([]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, AsyncValue<List<Article>>>((ref) {
  return SearchNotifier(ref);
});
