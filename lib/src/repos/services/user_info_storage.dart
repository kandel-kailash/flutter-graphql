import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:github_graphql_app/core/shared/model/user/user.dart';

class LoginUserStorage {
  LoginUserStorage() : _secureStorage = const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  User? _cachedUser;

  static const _key = 'user_info';

  Future<void> save(User user) async {
    _cachedUser = user;

    await _secureStorage.write(key: _key, value: jsonEncode(user.toJson()));
  }

  Future<User?> read() async {
    if (_cachedUser != null) {
      return _cachedUser!;
    }

    try {
      final userString = await _secureStorage.read(key: _key);

      if (userString == null) {
        return null;
      }

      return _cachedUser = User.fromJson(jsonDecode(userString));
    } catch (error, stackTrace) {
      debugPrintStack(
        stackTrace: stackTrace,
        label: 'UserInfoStorage.read: $error',
      );
      return null;
    }
  }

  Future<void> clear() {
    _cachedUser = null;
    return _secureStorage.delete(key: _key);
  }
}
