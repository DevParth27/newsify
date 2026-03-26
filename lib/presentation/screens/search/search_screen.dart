import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../providers/search_provider.dart';
import '../../widgets/news/article_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchProvider);
    final queryEmpty = _searchController.text.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Search news',
            onChanged: (value) {
              ref.read(searchProvider.notifier).search(value);
            },
          ),
        ),
        Expanded(
          child: queryEmpty
              ? Center(
                  child: Text(
                    'Enter a search query',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : searchAsync.when(
                  data: (articles) {
                    if (articles.isEmpty) {
                      return Center(
                        child: Text(
                          'No results',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ArticleCard(article: articles[index]),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      e is Failure ? e.message : e.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
