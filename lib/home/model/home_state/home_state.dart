import 'package:github_graphql_app/home/model/github_repository/github_repository.dart';
import 'package:github_graphql_app/home/model/user/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const HomeState._();
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = _Loading;
  const factory HomeState.loaded({
    required User user,
    required List<GithubRepository> repos,
  }) = _Loaded;
  const factory HomeState.failure(String message) = _Failure;
}