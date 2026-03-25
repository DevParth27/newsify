import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/article.dart';
import '../../repositories/news_repository.dart';

class SaveFavorite {
  final NewsRepository newsRepository;

  SaveFavorite(this.newsRepository);

  Future<Either<Failure, Unit>> call(Article article) {
    return newsRepository.saveFavorite(article);
  }
}
