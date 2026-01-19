import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:github_graphql_app/src/auth/view_modal/auth_cubit.dart';
import 'package:github_graphql_app/core/constants/queries.dart';
import 'package:github_graphql_app/core/routes/app_route_config.dart';
import 'package:github_graphql_app/src/repos/services/graphql_config.dart';
import 'package:github_graphql_app/src/repos/view_modal/list_view_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RepoDetailsView extends StatelessWidget {
  const RepoDetailsView({super.key, required this.repositoryName});

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

    switch (orientation) {
      case Orientation.portrait:
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(repositoryName),
            leading: BackButton(
              onPressed: () => context.goNamed(AppRouteConfig.repos.name),
            ),
          ),
          body: detailsView,
        );
      case Orientation.landscape:
        final isDetailsRoute =
            GoRouter.of(context).state.name == AppRouteConfig.details.name;

        // Wait for the details view to be rendered before navigating to the
        // details sub-route in the landscape mode.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isDetailsRoute) {
            context.goNamed(
              AppRouteConfig.detailsSubRouteName,
              pathParameters: {'repoName': repositoryName},
            );
          }
        });

        return isDetailsRoute ? const SizedBox() : detailsView;
    }
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
        builder:
            (
              QueryResult<Object> result, {
              FetchMore<Object>? fetchMore,
              Refetch<Object>? refetch,
            }) {
              final String? readme =
                  result.data?['repository']?['object']?['text'];

              return readme == null
                  ? Center(child: Text(repositoryName))
                  : TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0.0,
                        end: result.isLoading ? 0.0 : 1.0,
                      ),
                      curve: Curves.easeInCirc,
                      duration: const Duration(milliseconds: 300),
                      builder: (_, opacity, __) {
                        return Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: opacity,
                            child: Markdown(
                              data: readme,
                              onTapLink:
                                  (
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
                            ),
                          ),
                        );
                      },
                    );
            },
      ),
    );
  }
}
