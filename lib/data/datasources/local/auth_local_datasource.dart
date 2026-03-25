import 'package:hive/hive.dart';

import '../../../domain/entities/user.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._box);

  static const String boxName = 'auth_box';

  final Box<dynamic> _box;

  static const String _keyLoggedIn = 'is_logged_in';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';

  Future<void> saveLoginState(bool value) async {
    await _box.put(_keyLoggedIn, value);
  }

  Future<void> clearLoginState() async {
    await _box.delete(_keyLoggedIn);
    await _box.delete(_keyUserName);
    await _box.delete(_keyUserEmail);
  }

  bool isLoggedIn() {
    return _box.get(_keyLoggedIn, defaultValue: false) as bool;
  }

  Future<void> saveUser(User user) async {
    await _box.put(_keyUserName, user.name);
    await _box.put(_keyUserEmail, user.email);
  }

  User? getUser() {
    final name = _box.get(_keyUserName) as String?;
    final email = _box.get(_keyUserEmail) as String?;
    if (name == null || email == null) {
      return null;
    }
    return User(name: name, email: email);
  }
}
