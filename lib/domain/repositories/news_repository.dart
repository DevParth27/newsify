import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/article.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<Article>>> getTopHeadlines(
    String category,
    int page,
  );

  Future<Either<Failure, List<Article>>> searchArticles(
    String query,
    int page,
  );

  Future<Either<Failure, Unit>> saveFavorite(Article article);

  Future<Either<Failure, Unit>> removeFavorite(String url);

  Future<Either<Failure, List<Article>>> getFavorites();
}
