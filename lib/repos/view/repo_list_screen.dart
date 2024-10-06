import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_graphql_app/auth/services/authentication/github_authenticator.dart';
import 'package:github_graphql_app/core/shared/screen_width.dart';
import 'package:github_graphql_app/core/views/responsive_view.dart';
import 'package:github_graphql_app/repos/model/state/repos_state.dart';
import 'package:github_graphql_app/repos/services/graphql_config.dart';
import 'package:github_graphql_app/repos/view/widgets/custom_app_bar.dart';
import 'package:github_graphql_app/repos/view/widgets/repo_tile.dart';
import 'package:github_graphql_app/repos/view_modal/repos_cubit.dart';

sealed class RepoListView extends StatelessWidget implements ResponsiveView {
  const RepoListView({super.key});

  @override
  factory RepoListView.responsive(BuildContext context) {
    return switch (ScreenWidth.from(context)) {
      ScreenWidth.phone => const _RepoListPortraitView(),
      ScreenWidth.tablet => const _RepoListTabletView(),
      ScreenWidth.desktop => throw UnimplementedError(),
    };
  }
}

class _RepoListPortraitView extends RepoListView {
  const _RepoListPortraitView();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReposCubit(
        GraphQLConfig(context.read<GithubAuthenticator>()),
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.search_rounded),
            ),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(double.maxFinite),
              child: BlocBuilder<ReposCubit, ReposState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    orElse: () {
                      return const CustomAppBar();
                    },
                    loaded: (user, _) {
                      return CustomAppBar(user: user);
                    },
                  );
                },
              ),
            ),
            body: BlocBuilder<ReposCubit, ReposState>(
              builder: (context, state) {
                return state.maybeWhen(
                  orElse: () {
                    return const Center(
                      child: Text('No repos'),
                    );
                  },
                  loaded: (_, repos) {
                    return NotificationListener<ScrollNotification>(
                      onNotification: context.read<ReposCubit>().onScroll,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 90, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20.0,
                                top: 10,
                              ),
                              child: Text(
                                'Repositories',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontStyle: FontStyle.italic,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.blueGrey,
                                      offset: Offset(0, -5),
                                    )
                                  ],
                                  color: Colors.transparent,
                                  decoration: TextDecoration.combine(
                                    [
                                      TextDecoration.underline,
                                      TextDecoration.underline,
                                    ],
                                  ),
                                  decorationColor: Colors.deepPurpleAccent,
                                  decorationThickness: 2,
                                  decorationStyle: TextDecorationStyle.wavy,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...List.generate(
                              repos.length + 2,
                              (index) {
                                return (index < repos.length)
                                    ? RepoTile(
                                        repo: repos[index],
                                      )
                                    : Container();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _RepoListTabletView extends RepoListView {
  const _RepoListTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return switch (orientation) {
          Orientation.portrait => const _RepoListPortraitView(),
          Orientation.landscape => const _RepoListLandscapeView(),
        };
      },
    );
  }
}

class _RepoListLandscapeView extends StatelessWidget {
  const _RepoListLandscapeView();

  @override
  Widget build(BuildContext context) {
    // TODO @kailash: Create nested navigation for tablets and desktop screens
    return const Placeholder();
  }
}
