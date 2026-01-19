import 'dart:collection';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_graphql_app/core/constants/queries.dart';
import 'package:github_graphql_app/src/repos/model/state/search_view_result.dart';
import 'package:github_graphql_app/src/repos/model/state/search_view_state.dart';
import 'package:github_graphql_app/src/repos/services/graphql_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SearchViewCubit extends Cubit<SearchViewState> {
  SearchViewCubit([this._result = const []])
    : super(const SearchViewInitialState());

  final List<SearchViewResult> _result;

  String? _endCursor;

  UnmodifiableListView<SearchViewResult> get results =>
      UnmodifiableListView(_result);

  GraphQLClient get _graphQLClient => GraphQLConfig().client;

  void addResults(List<SearchViewResult> results) {
    _result.addAll(results);
    emit(SearchViewLoadedState(result: results));
  }

  void searchUser(String name) async {
    try {
      if (name.isEmpty) return emit(const SearchViewInitialState());

      emit(const SearchViewLoadingState());

      final options = WatchQueryOptions(
        document: gql(searchUsers),
        variables: {'nUsers': 25, 'query': name, 'after': _endCursor},
        pollInterval: const Duration(seconds: 5),
        fetchResults: true,
      );

      final result = await _graphQLClient.query(options);

      if (result.hasException) {
        log(result.exception.toString());
        return emit(SearchViewFailureState(result.exception.toString()));
      }

      final nodes = result.data?['search']['nodes'];

      final nodesLength = nodes?.length ?? 0;

      final List<SearchViewResult> data = List.generate(
        nodesLength,
        (index) => SearchViewResult.fromJson(nodes![index]),
      );

      emit(SearchViewLoadedState(result: data));
    } catch (error, stackTrace) {
      debugPrintStack(
        label: 'SearchViewCubit.searchUser: $error',
        stackTrace: stackTrace,
      );
    }
  }

  void onScroll(ScrollNotification notification) {}
}
