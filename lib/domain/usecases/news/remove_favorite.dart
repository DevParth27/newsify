import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/news_repository.dart';

class RemoveFavorite {
  final NewsRepository newsRepository;

  RemoveFavorite(this.newsRepository);

  Future<Either<Failure, Unit>> call(String url) {
    return newsRepository.removeFavorite(url);
  }
}
