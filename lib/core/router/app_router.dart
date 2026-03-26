import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/article.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/article_detail/article_detail_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/news_feed/news_feed_screen.dart';
import '../../presentation/screens/search/search_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authProvider);
  final isAuthenticated = authAsync.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/feed',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoginRoute = location == '/login';

      if (!isAuthenticated && !isLoginRoute) return '/login';
      if (isAuthenticated && isLoginRoute) return '/feed';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return BottomNavShell(
            location: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/feed',
            name: 'feed',
            builder: (context, state) => const NewsFeedScreen(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/article',
        name: 'article',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Article) {
            return const Scaffold(
              body: Center(child: Text('Missing article')),
            );
          }
          return ArticleDetailScreen(article: extra);
        },
      ),
    ],
  );
});

class BottomNavShell extends StatelessWidget {
  final Widget child;
  final String location;

  const BottomNavShell({
    super.key,
    required this.child,
    required this.location,
  });

  int _selectedIndex() {
    switch (location) {
      case '/feed':
        return 0;
      case '/search':
        return 1;
      case '/favorites':
        return 2;
      default:
        return 0;
    }
  }

  String _label() {
    switch (location) {
      case '/feed':
        return 'Feed';
      case '/search':
        return 'Search';
      case '/favorites':
        return 'Favorites';
      default:
        return 'News';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex();
    final title = _label();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/feed');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              context.go('/favorites');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_outlined),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
