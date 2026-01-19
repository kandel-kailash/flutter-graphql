import 'package:flutter/widgets.dart';
import 'package:github_graphql_app/core/constants/urls.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:oauth2/oauth2.dart';
import 'package:path_provider/path_provider.dart';

class GraphQLConfig extends ChangeNotifier {
  GraphQLConfig._();

  factory GraphQLConfig() {
    if (_instance != null) return _instance!;

    _instance = GraphQLConfig._();
    return _instance!;
  }

  static GraphQLConfig? _instance;

  static const _cacheStorageName = 'github_cache';

  bool _isInitialized = false;

  GraphQLClient? _client;

  bool get isInitialized => _isInitialized;

  HttpLink get _httpLink => HttpLink(graphQLEndpoint);

  GraphQLClient get client =>
      _client ?? (throw Exception('Client not initialized'));

  Link _getLink(Credentials credentials) {
    final authLink = AuthLink(
      getToken: () async => 'Bearer ${credentials.accessToken}',
    );

    final Link link = authLink.concat(_httpLink);

    return link;
  }

  Future<HiveStore> _getCacheStorage() async {
    try {
      final cacheDirectory = await getTemporaryDirectory();
      final cacheDirectoryPath = cacheDirectory.path;

      return HiveStore.open(
        boxName: _cacheStorageName,
        path: cacheDirectoryPath,
      );
    } on MissingPlatformDirectoryException {
      return HiveStore.open(boxName: _cacheStorageName);
    }
  }

  Future<GraphQLClient> initializeClient(Credentials credentials) async {
    final Link link = _getLink(credentials);

    final cache = await _getCacheStorage();
    final gqlCache = GraphQLCache(store: cache);

    _client = GraphQLClient(link: link, cache: gqlCache);

    _isInitialized = true;

    notifyListeners();

    return _client!;
  }

  void resetClient() => _client = null;
}
