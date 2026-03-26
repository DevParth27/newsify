import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);

  final AuthLocalDataSource _local;

  static const String _demoEmail = 'demo@newsapp.com';
  static const String _demoPassword = 'password123';

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      if (email == _demoEmail && password == _demoPassword) {
        const user = User(
          name: 'Demo User',
          email: _demoEmail,
        );
        await _local.saveLoginState(true);
        await _local.saveUser(user);
        return const Right(user);
      }
      return const Left(ServerFailure('Invalid credentials.'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _local.clearLoginState();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  bool isLoggedIn() {
    return _local.isLoggedIn();
  }

  @override
  User? getCurrentUser() {
    if (!isLoggedIn()) return null;
    return _local.getUser();
  }
}
