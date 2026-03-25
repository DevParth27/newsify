import '../../repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository authRepository;

  CheckAuthStatus(this.authRepository);

  bool call() {
    return authRepository.isLoggedIn();
  }
}
