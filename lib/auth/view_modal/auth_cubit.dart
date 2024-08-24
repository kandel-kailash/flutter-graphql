import 'package:bloc/bloc.dart';
import 'package:github_graphql_app/auth/modal/auth_state.dart';
import 'package:github_graphql_app/auth/services/authentication/github_authenticator.dart';

typedef AuthUriCallback = Future<Uri> Function(Uri authorizationUrl);

///
/// Application abstraction to handle authentication
/// ==> uses [ GithubAuthenticator ] service
/// ==> produces [ AuthState] that is used by the presentation layer
///
class AuthBloc extends Cubit<AuthState> {
  final GithubAuthenticator _authenticator;

  AuthBloc(this._authenticator) : super(const AuthState.initial()) {
    checkAndUpdateAuthStatus();
  }

  Future<void> checkAndUpdateAuthStatus() async {
    emit(
      (await _authenticator.isSignedIn())
          ? const AuthState.authenticated()
          : const AuthState.unauthenticated(),
    );
  }

  Future<void> signIn(AuthUriCallback authorizationCallback) async {
    // 1. create grant to get authorization url
    final grant = _authenticator.createGrant();

    /// 2. callback is called from view
    ///    takes in [ authorizationUrl ] returned by the [ getAuthorizationUrl]
    ///    returns a [ Uri ] which is the redirect Uri that contains the [ code]
    final redirectUrl = await authorizationCallback(
      _authenticator.getAuthorizationUrl(grant),
    );

    /// 3. handles if user is autheticated or not
    ///    returns [ AuthFailure ] if failure
    ///    [ Unit ] if success
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
