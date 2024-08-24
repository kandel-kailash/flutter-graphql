import 'package:github_graphql_app/home/model/home_state/home_state.dart';
import 'package:github_graphql_app/home/model/github_repository/github_repository.dart';
import 'package:github_graphql_app/home/model/user/user.dart';
import 'package:github_graphql_app/home/services/graphql_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HomeCubit extends Cubit<HomeState> {
  final GraphQLConfig _graphQLConfig;

  final List<GithubRepository> githubRepos = [];

  bool hasNextPage;
  String? endCursor;

  HomeCubit(
    this._graphQLConfig, [
    this.hasNextPage = true,
  ]) : super(const HomeState.initial()) {
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final graphQLClient = await _graphQLConfig.getClient();

    if (graphQLClient == null) {
      emit(
        const HomeState.failure('Failure while creating client'),
      );
      return;
    }

    emit(const HomeState.loading());

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
        HomeState.failure(
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
      HomeState.loaded(
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
