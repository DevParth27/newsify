import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authProvider = StateProvider<bool>((ref) => false);

final goRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(authProvider);

  return GoRouter(
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
        builder: (context, state) => const LoginPage(),
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
            builder: (context, state) => const FeedPage(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            builder: (context, state) => const FavoritesPage(),
          ),
          GoRoute(
            path: '/article',
            name: 'article',
            builder: (context, state) => const ArticlePage(),
          ),
        ],
      ),
    ],
  );
});

class BottomNavShell extends StatelessWidget {
  final Widget child;
  final String location;

  const BottomNavShell({
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
      case '/article':
        return 3;
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
      case '/article':
        return 'Article';
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
            case 3:
              context.go('/article');
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
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'Article',
          ),
        ],
      ),
    );
  }
}

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isAuthenticated ? 'Logged in' : 'Login',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.read(authProvider.notifier).state = true;
                context.go('/feed');
              },
              child: const Text('Continue'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).state = false;
              },
              child: const Text('Use demo login'),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Top stories',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/article'),
              child: const Text('Open article'),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Search',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/article'),
              child: const Text('View result'),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Favorites',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/article'),
              child: const Text('Read saved'),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Article',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/feed'),
              child: const Text('Back to feed'),
            ),
          ],
        ),
      ),
    );
  }
}

