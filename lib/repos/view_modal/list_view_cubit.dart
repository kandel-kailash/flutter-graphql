import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_graphql_app/core/constants/queries.dart';
import 'package:github_graphql_app/repos/model/github_repository/github_repository.dart';
import 'package:github_graphql_app/repos/model/state/list_view_state.dart';
import 'package:github_graphql_app/repos/model/user/user.dart';
import 'package:github_graphql_app/repos/services/graphql_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

typedef ParsedResult = ({User owner, Set<GithubRepository> repos});

class ListViewCubit extends Cubit<ListViewState> {
  ListViewCubit([
    this.hasNextPage = true,
  ]) : super(const ListViewState.initial()) {
    fetchUserData();
  }

  bool hasNextPage;
  String? endCursor;

  GraphQLClient get _graphQLClient => GraphQLConfig().client;

  /// Should be set after choosing a user from the list
  /// And should be used for the login name when fetching the repositories
  static User? _currentOwner;

  final Set<GithubRepository> _repos = {};

  static User? get currentOwner => _currentOwner;

  UnmodifiableListView<GithubRepository> get repos =>
      UnmodifiableListView(_repos);

  ParsedResult _parseUserResult(Map<String, dynamic> result) {
    _currentOwner = User.fromJson(result);

    _repos.addAll(List.generate(
      result['repositories']['edges'].length,
      (index) => GithubRepository.fromJson(
        result['repositories']['edges'][index]['node'],
      ),
    ).toSet());

    hasNextPage = result['repositories']['pageInfo']['hasNextPage'];
    endCursor = result['repositories']['pageInfo']['endCursor'];

    return (
      owner: _currentOwner!,
      repos: _repos,
    );
  }

  void _resetState() {
    endCursor = '';
    hasNextPage = true;

    _repos.clear();

    emit(const ListViewState.reset());
  }

  Future<void> fetchUserData([User? user]) async {
    if (user != null && user != _currentOwner) {
      _resetState();
      _currentOwner = user;
    }

    emit(const ListViewState.loading());

    final options = WatchQueryOptions(
      document: gql(_currentOwner == null ? readRepositories : readUser),
      variables: {
        'nRepos': 25,
        if (_currentOwner != null) 'login': _currentOwner!.login,
        'after': endCursor,
      },
      pollInterval: const Duration(seconds: 5),
      fetchResults: true,
    );

    final result = await _graphQLClient.query(options);

    if (result.hasException) {
      emit(
        ListViewState.failure(
          result.exception.toString(),
        ),
      );

      return;
    }

    final (
      :User owner,
      :Set<GithubRepository> repos,
    ) = _parseUserResult(
      _currentOwner == null ? result.data!['viewer'] : result.data!['user'],
    );

    emit(
      ListViewState.loaded(
        user: owner,
        repos: repos,
      ),
    );
  }

  bool onScroll() {
    if (hasNextPage) fetchUserData();
    return true;
  }
}
