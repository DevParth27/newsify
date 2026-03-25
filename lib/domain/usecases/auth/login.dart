import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class Login {
  final AuthRepository authRepository;

  Login(this.authRepository);

  Future<Either<Failure, User>> call(String email, String password) {
    return authRepository.login(email, password);
  }
}
