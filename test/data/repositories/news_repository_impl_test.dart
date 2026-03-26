import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:newsify/core/errors/failures.dart';
import 'package:newsify/domain/entities/article.dart';
import 'package:newsify/data/datasources/local/news_local_datasource.dart';
import 'package:newsify/data/datasources/remote/news_remote_datasource.dart';
import 'package:newsify/data/repositories/news_repository_impl.dart';

class MockNewsRemoteDataSource extends Mock implements NewsRemoteDataSource {}

class MockNewsLocalDataSource extends Mock implements NewsLocalDataSource {}

void main() {
  late MockNewsRemoteDataSource mockRemote;
  late MockNewsLocalDataSource mockLocal;
  late NewsRepositoryImpl repo;

  setUp(() {
    mockRemote = MockNewsRemoteDataSource();
    mockLocal = MockNewsLocalDataSource();
    repo = NewsRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  test('returns NetworkFailure when remote throws connection error', () async {
    when(() => mockRemote.getTopHeadlines(any(), any())).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/top-headlines'),
        type: DioExceptionType.connectionError,
      ),
    );

    final result = await repo.getTopHeadlines('business', 1);

    expect(result, isA<Left<Failure, List<Article>>>());
    result.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
