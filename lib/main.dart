import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/auth_local_datasource.dart';
import 'data/datasources/local/news_local_datasource.dart';
import 'data/datasources/remote/news_remote_datasource.dart';
import 'data/models/article_model.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/news_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/news_feed_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  Hive.registerAdapter(ArticleModelAdapter());
  await Hive.openBox<dynamic>(AuthLocalDataSource.boxName);
  await Hive.openBox<ArticleModel>(NewsLocalDataSource.boxName);

  final authBox = Hive.box<dynamic>(AuthLocalDataSource.boxName);
  final favoritesBox = Hive.box<ArticleModel>(NewsLocalDataSource.boxName);

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          AuthRepositoryImpl(AuthLocalDataSource(authBox)),
        ),
        newsRepositoryProvider.overrideWithValue(
          NewsRepositoryImpl(
            remoteDataSource: NewsRemoteDataSource(DioClient.dio),
            localDataSource: NewsLocalDataSource(favoritesBox),
          ),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final appRouter = ref.watch(goRouterProvider);
    final appTheme = AppTheme.darkTheme;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: appRouter,
    );
  }
}
