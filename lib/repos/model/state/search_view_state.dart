import 'package:github_graphql_app/repos/model/state/search_view_result.dart';

sealed class SearchViewState {
  const SearchViewState();
}

class SearchViewInitialState extends SearchViewState {
  const SearchViewInitialState();
}

class SearchViewLoadingState extends SearchViewState {
  const SearchViewLoadingState();
}

class SearchViewLoadedState extends SearchViewState {
  const SearchViewLoadedState({required this.result});

  final List<SearchViewResult> result;
}

class SearchViewFailureState extends SearchViewState {
  const SearchViewFailureState(
      [this.message = 'Something went wrong while loading the view']);

  final String message;

  @override
  String toString() =>
      'SearchViewFailureState(message: No data available: $message)';
}
