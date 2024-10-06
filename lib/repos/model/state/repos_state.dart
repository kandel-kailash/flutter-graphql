import 'package:github_graphql_app/repos/model/github_repository/github_repository.dart';
import 'package:github_graphql_app/repos/model/user/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'repos_state.freezed.dart';

@freezed
class ReposState with _$ReposState {
  const ReposState._();
  const factory ReposState.initial() = _Initial;
  const factory ReposState.loading() = _Loading;
  const factory ReposState.loaded({
    required User user,
    required List<GithubRepository> repos,
  }) = _Loaded;
  const factory ReposState.failure(String message) = _Failure;
}