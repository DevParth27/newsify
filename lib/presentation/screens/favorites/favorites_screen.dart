import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/favorites_provider.dart';
import '../../widgets/news/article_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(favoritesProvider);

    return async.when(
      data: (articles) {
        if (articles.isEmpty) {
          return Center(
            child: Text(
              'No saved articles yet',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            final key = article.url ?? article.title;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey(key),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  color: Theme.of(context).colorScheme.error,
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) {
                  final u = article.url;
                  if (u != null && u.isNotEmpty) {
                    ref.read(favoritesProvider.notifier).removeFavorite(u);
                  }
                },
                child: ArticleCard(article: article),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(e.toString()),
      ),
    );
  }
}
