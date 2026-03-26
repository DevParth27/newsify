import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:newsify/core/errors/failures.dart';
import 'package:newsify/domain/entities/article.dart';
import 'package:newsify/domain/repositories/news_repository.dart';
import 'package:newsify/domain/usecases/news/get_top_headlines.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

void main() {
  late MockNewsRepository mockRepo;
  late GetTopHeadlines usecase;

  setUp(() {
    mockRepo = MockNewsRepository();
    usecase = GetTopHeadlines(mockRepo);
  });

  test('returns article list on success', () async {
    final mockArticles = <Article>[
      const Article(title: 'Headline A', category: 'business'),
    ];
    when(() => mockRepo.getTopHeadlines(any(), any()))
        .thenAnswer((_) async => Right(mockArticles));

    final result = await usecase('business', 1);

    expect(result, isA<Right<Failure, List<Article>>>());
    expect(result.getOrElse(() => []), mockArticles);
    verify(() => mockRepo.getTopHeadlines('business', 1)).called(1);
  });
}
