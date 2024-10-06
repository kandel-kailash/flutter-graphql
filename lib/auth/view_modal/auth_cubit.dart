import 'package:bloc/bloc.dart';
import 'package:github_graphql_app/auth/modal/auth_state.dart';
import 'package:github_graphql_app/auth/services/authentication/github_authenticator.dart';

typedef AuthUriCallback = Future<Uri> Function(Uri authorizationUrl);

///
/// Application abstraction to handle authentication
/// ==> uses [ GithubAuthenticator ] service
/// ==> produces [ AuthState] that is used by the presentation layer
///
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authenticator) : super(const AuthState.initial()) {
    checkAndUpdateAuthStatus();
  }

  final GithubAuthenticator _authenticator;

  bool isStartUp = true;

  Future<void> checkAndUpdateAuthStatus() async {
    emit(
      (await _authenticator.isSignedIn())
          ? const AuthState.authenticated()
          : const AuthState.unauthenticated(),
    );
  }

  void authenticateUser() => emit(const AuthState.authenticated());

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
          grant, redirectUrl.queryParameters);

      // 4. push state in the stream
      emit(
        failOrSuccess.fold(
          (l) => AuthState.failure(l),
          (r) => const AuthState.authenticated(),
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
        (l) => AuthState.failure(l),
        (r) => const AuthState.unauthenticated(),
      ),
    );
  }
}
