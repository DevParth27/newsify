import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/local/news_local_datasource.dart';
import '../datasources/remote/news_remote_datasource.dart';
import '../models/article_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl({
    required NewsRemoteDataSource remoteDataSource,
    required NewsLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final NewsRemoteDataSource _remote;
  final NewsLocalDataSource _local;

  @override
  Future<Either<Failure, List<Article>>> getTopHeadlines(
    String category,
    int page,
  ) async {
    try {
      final models = await _remote.getTopHeadlines(category, page);
      return Right(models.map((ArticleModel m) => m.toEntity()).toList());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Article>>> searchArticles(
    String query,
    int page,
  ) async {
    try {
      final models = await _remote.searchArticles(query, page);
      return Right(models.map((ArticleModel m) => m.toEntity()).toList());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveFavorite(Article article) async {
    try {
      await _local.saveFavorite(ArticleModel.fromEntity(article));
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeFavorite(String url) async {
    try {
      await _local.removeFavorite(url);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Article>>> getFavorites() async {
    try {
      final models = _local.getFavorites();
      return Right(models.map((ArticleModel m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
