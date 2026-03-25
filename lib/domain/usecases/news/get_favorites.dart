import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/article.dart';
import '../../repositories/news_repository.dart';

class GetFavorites {
  final NewsRepository newsRepository;

  GetFavorites(this.newsRepository);

  Future<Either<Failure, List<Article>>> call() {
    return newsRepository.getFavorites();
  }
}
