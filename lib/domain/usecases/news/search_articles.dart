import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/article.dart';
import '../../repositories/news_repository.dart';

class SearchArticles {
  final NewsRepository newsRepository;

  SearchArticles(this.newsRepository);

  Future<Either<Failure, List<Article>>> call(String query, int page) {
    return newsRepository.searchArticles(query, page);
  }
}
