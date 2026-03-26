import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/article.dart';
import '../../providers/favorites_provider.dart';

class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final heroTag = 'article_image_${article.url ?? article.title}';
    final published = article.publishedAt;
    final timeLabel =
        published != null ? timeago.format(published, locale: 'en') : '';
    final favAsync = ref.watch(favoritesProvider);
    final url = article.url;
    final isFavorite = favAsync.maybeWhen(
      data: (list) => list.any((a) => a.url == url && url != null && url.isNotEmpty),
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: url == null || url.isEmpty
                ? null
                : () async {
                    final notifier = ref.read(favoritesProvider.notifier);
                    if (isFavorite) {
                      await notifier.removeFavorite(url);
                    } else {
                      await notifier.saveFavorite(article);
                    }
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              Hero(
                tag: heroTag,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, _) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (context, url, err) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              )
            else
              Hero(
                tag: heroTag,
                child: Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (article.source != null && article.source!.isNotEmpty)
                    Text(
                      article.source!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  if (timeLabel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      timeLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  if (article.description != null &&
                      article.description!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      article.description!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 28),
                  if (url != null && url.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () async {
                        final uri = Uri.tryParse(url);
                        if (uri == null) return;
                        try {
                          final ok = await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open link'),
                              ),
                            );
                          }
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open link'),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Read Full Article'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
