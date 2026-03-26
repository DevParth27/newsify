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

  @override
  Future<List<Article>> build(String category) async {
    _page = 1;
    final result =
        await ref.read(getTopHeadlinesUseCaseProvider).call(category, _page);
    return result.fold((failure) => throw failure, (articles) => articles);
  }

  Future<void> loadMore() async {
    final previous = state.valueOrNull ?? [];
    _page++;
    final result = await ref
        .read(getTopHeadlinesUseCaseProvider)
        .call(arg, _page);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (articles) => state = AsyncData([...previous, ...articles]),
    );
  }

  Future<void> refresh() async {
    _page = 1;
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
