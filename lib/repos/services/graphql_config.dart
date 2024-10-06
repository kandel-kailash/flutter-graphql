import 'package:github_graphql_app/auth/services/authentication/github_authenticator.dart';
import 'package:github_graphql_app/core/constants/urls.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:path_provider/path_provider.dart';

class GraphQLConfig {
  final GithubAuthenticator _githubAuthenticator;

  static const cacheStorageName = 'github_cache';

  GraphQLConfig(this._githubAuthenticator);

  HttpLink get _httpLink => HttpLink(graphQLEndpoint);

  Future<AuthLink?> _getAuthLink() async {
    final credentials = await _githubAuthenticator.getSignedInCredentials();

    if (credentials == null) {
      return null;
    }

    return AuthLink(getToken: () async => 'Bearer ${credentials.accessToken}');
  }

  Future<Link?> _getLink() async {
    final authLink = await _getAuthLink();

    if (authLink == null) {
      return null;
    }

    final link = authLink.concat(_httpLink);

    /// subscriptions must be split otherwise `HttpLink` will swallow them
    // return Link.split(
    //   (request) => request.isSubscription,
    //   link,
    //   WebSocketLink(graphQLEndpoint),
    // );

    return link;
  }

  Future<HiveStore> _getCacheStorage() async {
    try {
      final cacheDirectory = await getTemporaryDirectory();
      final cacheDirectoryPath = cacheDirectory.path;

      return HiveStore.open(
        boxName: cacheStorageName,
        path: cacheDirectoryPath,
      );
    } on MissingPlatformDirectoryException {
      return HiveStore.open(
        boxName: cacheStorageName,
      );
    }
  }

  Future<GraphQLClient?> getClient() async {
    final link = await _getLink();
    if (link == null) {
      return null;
    }

    final cache = await _getCacheStorage();
    final gqlCache = GraphQLCache(store: cache);

    return GraphQLClient(link: link, cache: gqlCache);
  }
}

const readRepositories = r'''
  query ReadRepositories($user: String = "josevalim", $nRepos: Int!, $after: String){ 
    user(login: $user) { 
      id
      name
      avatarUrl
      repositories(first: $nRepos, after: $after) {
        pageInfo {
          hasNextPage
          endCursor
        }
        edges {
          node {
            id
            name
            stargazerCount
          }
        }
      } 
    }
  }
''';

const searchRepos = r'''
  query SearchRepositories($nRepositories: Int!, $query: String!, $cursor: String) {
    search(last: $nRepositories, query: $query, type: REPOSITORY, after: $cursor) {
      nodes {
        __typename
        ... on Repository {
          name
          shortDescriptionHTML
          viewerHasStarred
          stargazers {
            totalCount
          }
          forks {
            totalCount
          }
          updatedAt
        }
      }
      pageInfo {
        endCursor
        hasNextPage
      }
    }
  }
''';
