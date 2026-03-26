import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article.dart';
import '../../domain/usecases/news/get_favorites.dart';
import '../../domain/usecases/news/remove_favorite.dart';
import '../../domain/usecases/news/save_favorite.dart';
import 'news_feed_provider.dart';

final getFavoritesUseCaseProvider = Provider<GetFavorites>((ref) {
  return GetFavorites(ref.watch(newsRepositoryProvider));
});

final saveFavoriteUseCaseProvider = Provider<SaveFavorite>((ref) {
  return SaveFavorite(ref.watch(newsRepositoryProvider));
});

final removeFavoriteUseCaseProvider = Provider<RemoveFavorite>((ref) {
  return RemoveFavorite(ref.watch(newsRepositoryProvider));
});

class FavoritesNotifier extends AsyncNotifier<List<Article>> {
  @override
  Future<List<Article>> build() async {
    final result = await ref.read(getFavoritesUseCaseProvider).call();
    return result.fold((failure) => throw failure, (articles) => articles);
  }

  Future<void> saveFavorite(Article article) async {
    final result = await ref.read(saveFavoriteUseCaseProvider).call(article);
    result.fold(
      (failure) => throw failure,
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> removeFavorite(String url) async {
    final result = await ref.read(removeFavoriteUseCaseProvider).call(url);
    result.fold(
      (failure) => throw failure,
      (_) => ref.invalidateSelf(),
    );
  }

  bool isFavorite(String url) {
    return state.valueOrNull?.any((a) => a.url == url) ?? false;
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<Article>>(
  FavoritesNotifier.new,
);
