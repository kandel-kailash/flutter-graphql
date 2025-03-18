import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:github_graphql_app/auth/modal/auth_failure.dart';
import 'package:github_graphql_app/auth/services/credentials_storage/credentials_storage.dart';
import 'package:github_graphql_app/core/constants/urls.dart';
import 'package:github_graphql_app/core/extensions/dio_extensions.dart';
import 'package:github_graphql_app/core/shared/services/encoders.dart';
import 'package:github_graphql_app/core/utils/either.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart';

/// New [ HttpClient ] with [ Accept : application/json] header
class GithubOAuthHttpClient extends http.BaseClient {
  final httpClient = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return httpClient.send(request);
  }
}

class GithubAuthenticator {
  GithubAuthenticator(
    this._dio,
    this._credentialsStorage,
  );

  final Dio _dio;
  final CredentialsStorage _credentialsStorage;

  static const _clientId = String.fromEnvironment('clientId');
  static const _clientSecret = String.fromEnvironment('clientSecret');

  static const scopes = ['read:user', 'repo'];
  static const revocationEndpoint =
      'https://api.github.com/applications/$_clientId/token';

  static Uri get redirectUri => Uri.parse(redirectUrl);

  Future<Credentials?> getSignedInCredentials() async {
    try {
      final storedCredentials = await _credentialsStorage.read();
      return storedCredentials;
    } on PlatformException {
      return null;
    }
  }

  AuthorizationCodeGrant get grant => AuthorizationCodeGrant(
        _clientId,
        Uri.parse(authEndpoint),
        Uri.parse(tokenEndpoint),
        secret: _clientSecret,
        httpClient: GithubOAuthHttpClient(),
      );

  Uri getAuthorizationUrl(AuthorizationCodeGrant grant) =>
      grant.getAuthorizationUrl(
        redirectUri,
        scopes: scopes,
      );

  Future<Either<AuthFailure, Credentials>> handleAuthorizationResponse(
    AuthorizationCodeGrant grant,
    Map<String, String> queryParams,
  ) async {
    try {
      final httpClient = await grant.handleAuthorizationResponse(queryParams);
      final credentials = httpClient.credentials;

      await _credentialsStorage.save(credentials);
      return EitherX.right(credentials);
    } on FormatException {
      return EitherX.left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return EitherX.left(AuthFailure.server('${e.error}: ${e.description}'));
    } on PlatformException {
      return EitherX.left(const AuthFailure.storage());
    }
  }

  Future<Either<AuthFailure, Unit>> signOut() async {
    final accessToken = await _credentialsStorage
        .read()
        .then((credentials) => credentials?.accessToken);

    final encodedCredentials =
        stringToBase64.encode('$_clientId:$_clientSecret');

    try {
      try {
        _dio.delete(
          revocationEndpoint,
          data: {
            'access_token': accessToken,
          },
          options: Options(
            headers: {'Authorization': 'basic $encodedCredentials'},
          ),
        );
      } on DioException catch (e) {
        if (e.isNoConnectionError) {
        } else {
          rethrow;
        }
      }

      await _credentialsStorage.clear();
      return EitherX.right(const Unit());
    } on PlatformException {
      return EitherX.left(const AuthFailure.storage());
    }
  }
}
