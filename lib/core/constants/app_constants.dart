import 'package:dotenv/dotenv.dart';

final _env = DotEnv(includePlatformEnvironment: true);
bool _envLoaded = false;

class AppConstants {
  static const String apiBaseUrl = "https://newsapi.org/v2";

  static String get newsApiKey {
    if (!_envLoaded) {
      _env.load(const ['.env']);
      _envLoaded = true;
    }
    return _env['NEWS_API_KEY'] ?? '';
  }

  static const String authBox = "authBox";
  static const String favoritesBox = "favoritesBox";
  static const String cacheBox = "cacheBox";

  static const List<String> categories = [
    "business",
    "entertainment",
    "general",
    "health",
    "science",
    "sports",
    "technology",
  ];

  static const int pageSize = 20;

  static const String demoEmail = "demo@newsify.app";
  static const String demoPassword = "demo1234";
}
