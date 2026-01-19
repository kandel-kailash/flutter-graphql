import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:github_graphql_app/src/auth/modal/auth_failure.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState.initial() = _Initial;

  const factory AuthState.authenticated() = _Authenticated;

  const factory AuthState.unauthenticated() = _Unauthenticated;

  const factory AuthState.failure(AuthFailure failure) = _Failure;
}
