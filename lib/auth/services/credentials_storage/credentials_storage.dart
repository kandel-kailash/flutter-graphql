import 'package:oauth2/oauth2.dart';

abstract interface class CredentialsStorage {
  ///
  /// Read credentials from the local storage
  /// Credentials can be null if user is not authenticated
  ///
  Future<Credentials?> read();

  ///
  /// Save credentials to local storage
  ///
  Future<void> save(Credentials credentials);

  ///
  /// Clear credentials when logged out
  ///
  Future<void> clear();
}
