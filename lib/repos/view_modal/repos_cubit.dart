import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_graphql_app/repos/model/github_repository/github_repository.dart';
import 'package:github_graphql_app/repos/model/state/repos_state.dart';
import 'package:github_graphql_app/repos/model/user/user.dart';
import 'package:github_graphql_app/repos/services/graphql_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ReposCubit extends Cubit<ReposState> {
  final GraphQLConfig _graphQLConfig;

  final List<GithubRepository> githubRepos = [];

  bool hasNextPage;
  String? endCursor;

  ReposCubit(
    this._graphQLConfig, [
    this.hasNextPage = true,
  ]) : super(const ReposState.initial()) {
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final graphQLClient = await _graphQLConfig.getClient();

    if (graphQLClient == null) {
      emit(
        const ReposState.failure('Failure while creating client'),
      );
      return;
    }

    emit(const ReposState.loading());

    final options = WatchQueryOptions(
      document: gql(readRepositories),
      variables: {
        'nRepos': 15,
        'after': endCursor,
      },
      pollInterval: const Duration(seconds: 5),
      fetchResults: true,
    );

    final result = await graphQLClient.query(options);

    if (result.hasException) {
      emit(
        ReposState.failure(
          result.exception.toString(),
        ),
      );

      return;
    }

    final userData = User.fromJson(result.data?['user']);
    final repos = List.generate(
      result.data?['user']['repositories']['edges'].length,
      (index) => GithubRepository.fromJson(
        result.data?['user']['repositories']['edges'][index]['node'],
      ),
    );

    githubRepos.addAll(repos);

    hasNextPage =
        result.data?['user']['repositories']['pageInfo']['hasNextPage'];
    endCursor = result.data?['user']['repositories']['pageInfo']['endCursor'];

    emit(
      ReposState.loaded(
        user: userData,
        repos: githubRepos,
      ),
    );
  }

  bool onScroll(ScrollNotification notification) {
    if (notification.metrics.pixels != notification.metrics.maxScrollExtent) {
      return false;
    }

    return state.maybeWhen(
      orElse: () {
        return false;
      },
      loaded: (_, __) {
        if (!hasNextPage) {
          return !hasNextPage;
        }

        fetchUserData();
        return false;
      },
    );
  }
}
