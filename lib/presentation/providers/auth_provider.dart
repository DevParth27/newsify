import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/check_auth_status.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/logout.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError();
});

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final repo = ref.read(authRepositoryProvider);
    if (!repo.isLoggedIn()) return null;
    return repo.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final result =
        await Login(ref.read(authRepositoryProvider)).call(email, password);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    final result = await Logout(ref.read(authRepositoryProvider)).call();
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  bool isLoggedIn() {
    return CheckAuthStatus(ref.read(authRepositoryProvider)).call();
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
