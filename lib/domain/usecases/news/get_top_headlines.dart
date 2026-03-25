import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/article.dart';
import '../../repositories/news_repository.dart';

class GetTopHeadlines {
  final NewsRepository newsRepository;

  GetTopHeadlines(this.newsRepository);

  Future<Either<Failure, List<Article>>> call(String category, int page) {
    return newsRepository.getTopHeadlines(category, page);
  }
}
