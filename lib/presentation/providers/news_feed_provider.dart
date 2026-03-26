import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/usecases/news/get_top_headlines.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  throw UnimplementedError();
});

final getTopHeadlinesUseCaseProvider = Provider<GetTopHeadlines>((ref) {
  return GetTopHeadlines(ref.watch(newsRepositoryProvider));
});

class NewsFeedNotifier extends FamilyAsyncNotifier<List<Article>, String> {
  int _page = 1;
  bool _loadMoreInFlight = false;

  @override
  Future<List<Article>> build(String category) async {
    _page = 1;
    _loadMoreInFlight = false;
    final result =
        await ref.read(getTopHeadlinesUseCaseProvider).call(category, _page);
    return result.fold((failure) => throw failure, (articles) => articles);
  }

  Future<void> loadMore() async {
    if (_loadMoreInFlight) return;

    final previous = state.valueOrNull ?? [];
    if (previous.isEmpty) return;

    final nextPage = _page + 1;
    _loadMoreInFlight = true;
    try {
      final result = await ref
          .read(getTopHeadlinesUseCaseProvider)
          .call(arg, nextPage);
      result.fold(
        (failure) => state = AsyncError(failure, StackTrace.current),
        (articles) {
          if (articles.isEmpty) {
            state = AsyncData(previous);
            return;
          }
          _page = nextPage;
          state = AsyncData([...previous, ...articles]);
        },
      );
    } finally {
      _loadMoreInFlight = false;
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _loadMoreInFlight = false;
    state = const AsyncLoading();
    final result =
        await ref.read(getTopHeadlinesUseCaseProvider).call(arg, _page);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (articles) => state = AsyncData(articles),
    );
  }
}

final newsFeedProvider =
    AsyncNotifierProvider.family<NewsFeedNotifier, List<Article>, String>(
  NewsFeedNotifier.new,
);
