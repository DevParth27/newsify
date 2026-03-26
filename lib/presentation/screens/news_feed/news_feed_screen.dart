import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../providers/news_feed_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/no_internet_banner.dart';
import '../../widgets/common/shimmer_list.dart';
import '../../widgets/news/article_card.dart';

class NewsFeedScreen extends ConsumerWidget {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = AppConstants.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const NoInternetBanner(),
        Expanded(
          child: DefaultTabController(
            length: categories.length,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: categories
                      .map((c) => Tab(text: c[0].toUpperCase() + c.substring(1)))
                      .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: categories
                        .map((c) => _NewsFeedTabContent(category: c))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsFeedTabContent extends ConsumerStatefulWidget {
  const _NewsFeedTabContent({required this.category});

  final String category;

  @override
  ConsumerState<_NewsFeedTabContent> createState() =>
      _NewsFeedTabContentState();
}

class _NewsFeedTabContentState extends ConsumerState<_NewsFeedTabContent> {
  late final ScrollController _scrollController;
  bool _releasedFromBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final nearBottom = pos.pixels >= pos.maxScrollExtent - 200;
    if (!nearBottom) {
      _releasedFromBottom = true;
      return;
    }
    if (!_releasedFromBottom) return;
    _releasedFromBottom = false;
    ref.read(newsFeedProvider(widget.category).notifier).loadMore();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(newsFeedProvider(widget.category));

    return async.when(
      data: (articles) {
        if (articles.isEmpty) {
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(newsFeedProvider(widget.category).notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No articles')),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(newsFeedProvider(widget.category).notifier).refresh(),
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ArticleCard(article: articles[index]),
              );
            },
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: ShimmerList(itemCount: 8),
      ),
      error: (e, _) => AppErrorWidget(
        message: e is Failure ? e.message : e.toString(),
        onRetry: () =>
            ref.read(newsFeedProvider(widget.category).notifier).refresh(),
      ),
    );
  }
}
