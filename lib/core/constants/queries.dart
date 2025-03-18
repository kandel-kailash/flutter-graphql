const readViewer = r'''
 {
  viewer {
    id
    name
    login
    avatarUrl
  }
}
''';

const readRepositories = r'''
  query ReadRepositories($nRepos: Int = 15, $after: String) {
    viewer {
      login
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

const readUser = r'''
query ReadUser($nRepos: Int = 15, $login: String!, $after: String) {
  user(login: $login) {
    id
    name
    login
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

const searchUsers = r'''
query SearchRepositories($nUsers: Int!, $query: String!, $cursor: String) {
  search(last: $nUsers, query: $query, type: USER, after: $cursor) {
    nodes {
      ... on User {
        id
        name
        login
        avatarUrl
        databaseId
      }
    }
    pageInfo {
      endCursor
      hasNextPage
    }
  }
}
''';

const String readmeQuery = r'''
query RepositoryReadme($owner: String!, $name: String!) {
  repository(owner: $owner, name: $name) {
    object(expression: "HEAD:README.md") {
      ... on Blob {
        text
      }
    }
  }
}
''';
