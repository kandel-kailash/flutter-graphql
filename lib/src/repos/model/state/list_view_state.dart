import 'package:github_graphql_app/core/shared/model/user/user.dart';
import 'package:github_graphql_app/src/repos/model/github_repository/github_repository.dart';

sealed class ListViewState {
  const ListViewState();

  const factory ListViewState.initial() = _Initial;
  const factory ListViewState.loading() = Loading;
  const factory ListViewState.loaded({
    required User user,
    required Set<GithubRepository> repos,
  }) = Loaded;
  const factory ListViewState.failure(String message) = Failure;
  const factory ListViewState.reset() = Reset;
}

final class _Initial extends ListViewState {
  const _Initial();
}

final class Loading extends ListViewState {
  const Loading();
}

final class Loaded extends ListViewState {
  const Loaded({required this.user, required this.repos});

  final User user;
  final Set<GithubRepository> repos;
}

final class Failure extends ListViewState {
  const Failure(this.message);

  final String message;
}

final class Reset extends ListViewState {
  const Reset();
}
