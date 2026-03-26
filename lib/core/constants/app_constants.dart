import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String apiBaseUrl = "https://newsapi.org/v2";

  static String get newsApiKey => dotenv.env['NEWS_API_KEY'] ?? '';

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

  static const String demoEmail = "demo@newsapp.com";
  static const String demoPassword = "password123";
}
