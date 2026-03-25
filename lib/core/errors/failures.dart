sealed class Failure {
  final String message;

  const Failure(this.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = "Network error."]);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = "Server error."]);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = "Cache error."]);
}

final class NoInternetFailure extends Failure {
  const NoInternetFailure([super.message = "No internet connection."]);
}

