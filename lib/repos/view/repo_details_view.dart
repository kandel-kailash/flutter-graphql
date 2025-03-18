import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:github_graphql_app/auth/view_modal/auth_cubit.dart';
import 'package:github_graphql_app/core/constants/queries.dart';
import 'package:github_graphql_app/core/routes/app_route_config.dart';
import 'package:github_graphql_app/repos/services/graphql_config.dart';
import 'package:github_graphql_app/repos/view_modal/list_view_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RepoDetailsView extends StatelessWidget {
  const RepoDetailsView({
    super.key,
    required this.repositoryName,
  });

  final String repositoryName;

  @override
  Widget build(BuildContext context) {
    final detailsView = CustomScrollView(
      controller: ScrollController(),
      slivers: [
        SliverFillRemaining(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _ReadMeMarkDownView(
              owner: AuthCubit.currentUser?.login ?? '',
              repositoryName: repositoryName,
            ),
          ),
        ),
      ],
    );

    final Orientation orientation = MediaQuery.of(context).orientation;

    return switch (orientation) {
      Orientation.portrait => Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(repositoryName),
            leading: BackButton(
              onPressed: () => context.goNamed(AppRouteConfig.repos.name),
            ),
          ),
          body: detailsView,
        ),
      Orientation.landscape => detailsView,
    };
  }
}

class _ReadMeMarkDownView extends StatelessWidget {
  const _ReadMeMarkDownView({
    required this.owner,
    required this.repositoryName,
  });

  final String owner;
  final String repositoryName;

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: ValueNotifier(GraphQLConfig().client),
      child: Query<Object>(
        options: QueryOptions(
          document: gql(readmeQuery),
          variables: {
            'owner': ListViewCubit.currentOwner?.login,
            'name': repositoryName,
          },
        ),
        builder: (
          QueryResult<Object> result, {
          FetchMore<Object>? fetchMore,
          Refetch<Object>? refetch,
        }) {
          final String? readme = result.data?['repository']?['object']?['text'];

          return readme == null
              ? Center(
                  child: Text(repositoryName),
                )
              : Markdown(
                  data: readme,
                  onTapLink: (
                    String text,
                    String? href,
                    String title,
                  ) async {
                    if (href != null) {
                      final uri = Uri.parse(href);

                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    }
                  },
                );
        },
      ),
    );
  }
}
