import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/dio_client.dart';
import '../../models/article_model.dart';

class NewsRemoteDataSource {
  NewsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<ArticleModel>> getTopHeadlines(String category, int page) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/top-headlines',
        queryParameters: <String, dynamic>{
          'country': 'us',
          'category': category,
          'page': page,
          'pageSize': AppConstants.pageSize,
        },
      );
      return _parseArticles(response.data, category: category);
    } on DioException catch (e) {
      throw DioClient.mapDioExceptionToFailure(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<List<ArticleModel>> searchArticles(String query, int page) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/everything',
        queryParameters: <String, dynamic>{
          'q': query,
          'page': page,
          'pageSize': AppConstants.pageSize,
          'sortBy': 'publishedAt',
        },
      );
      return _parseArticles(response.data, category: null);
    } on DioException catch (e) {
      throw DioClient.mapDioExceptionToFailure(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  List<ArticleModel> _parseArticles(
    Map<String, dynamic>? data, {
    required String? category,
  }) {
    if (data == null) {
      throw ServerFailure('Invalid response.');
    }
    final raw = data['articles'];
    if (raw is! List<dynamic>) {
      throw ServerFailure('Invalid response.');
    }
    return raw
        .map((dynamic e) => ArticleModel.fromJson(
              e as Map<String, dynamic>,
              category: category,
            ))
        .toList();
  }
}
