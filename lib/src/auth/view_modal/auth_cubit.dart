import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:github_graphql_app/core/constants/queries.dart';
import 'package:github_graphql_app/core/shared/model/user/user.dart';
import 'package:github_graphql_app/src/auth/modal/auth_state.dart';
import 'package:github_graphql_app/src/auth/services/authentication/github_authenticator.dart';
import 'package:github_graphql_app/src/repos/services/graphql_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:oauth2/oauth2.dart';

typedef AuthUriCallback = Future<Uri> Function(Uri authorizationUrl);

/// {@template auth_cubit}
/// Application abstraction to handle authentication.
///
/// It depends on [GithubAuthenticator] service for authentication and emits
/// [AuthState] that is used by the presentation layer.
/// {@endtemplate}
class AuthCubit extends Cubit<AuthState> {
  /// {@macro auth_cubit}
  AuthCubit(this._authenticator) : super(const AuthState.initial()) {
    checkAndUpdateAuthStatus();
  }

  final GithubAuthenticator _authenticator;

  static User? _currentUser;

  static User? get currentUser => _currentUser;

  GraphQLClient get _graphQLClient => GraphQLConfig().client;

  void _runInitialization(Credentials credentials) async {
    final gqlClient = await GraphQLConfig().initializeClient(credentials);
    await _initializeUser(gqlClient);
  }

  Future<void> _initializeUser(GraphQLClient? client) async {
    if (client == null) return;

    final query = WatchQueryOptions(
      document: gql(readViewer),
      pollInterval: const Duration(seconds: 5),
      fetchResults: true,
    );

    final result = await _graphQLClient.query(query);

    if (result.hasException) {
      debugPrint(result.exception.toString());
      return;
    }

    final user = User.fromJson(result.data!['viewer']);

    _currentUser = user;
  }

  Future<void> checkAndUpdateAuthStatus() async {
    final credentials = await _authenticator.getSignedInCredentials();

    if (credentials == null || credentials.isExpired) {
      emit(const AuthState.unauthenticated());
      return;
    }

    emit(const AuthState.authenticated());

    _runInitialization(credentials);
  }

  Future<void> signIn(AuthUriCallback authorizationCallback) async {
    try {
      // 1. Obtain a grant to get authorization url
      final grant = _authenticator.grant;

      // 2. Callback is called from view that
      //    - takes in the `authorizationUrl` returned by the `getAuthorizationUrl`
      //    - returns a `Uri` which is the redirect Uri that contains the `code`
      final redirectUrl = await authorizationCallback(
        _authenticator.getAuthorizationUrl(grant),
      );

      // 3. Handles if user is authenticated or not and returns [ AuthFailure ] if
      // failure, [ Unit ] if success
      final failOrSuccess = await _authenticator.handleAuthorizationResponse(
        grant,
        redirectUrl.queryParameters,
      );

      // 4. push state in the stream
      emit(
        failOrSuccess.fold(
          onLeft: (left) => AuthState.failure(left),
          onRight: (right) {
            _runInitialization(right);
            return const AuthState.authenticated();
          },
        ),
      );

      // 5. close the grant
      grant.close();
    } catch (e) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> signOut() async {
    final failOrSuccess = await _authenticator.signOut();

    emit(
      failOrSuccess.fold(
        onLeft: (left) => AuthState.failure(left),
        onRight: (_) {
          GraphQLConfig().resetClient();
          return const AuthState.unauthenticated();
        },
      ),
    );
  }
}
