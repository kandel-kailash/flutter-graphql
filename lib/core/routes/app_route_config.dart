import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_graphql_app/auth/modal/auth_screen_route_info.dart';
import 'package:github_graphql_app/auth/view/auth_screen.dart';
import 'package:github_graphql_app/auth/view/welcome_screen.dart';
import 'package:github_graphql_app/core/views/splash_screen.dart';
import 'package:github_graphql_app/repos/services/graphql_config.dart';
import 'package:github_graphql_app/repos/services/user_info_storage.dart';
import 'package:github_graphql_app/repos/view/repo_details_view.dart';
import 'package:github_graphql_app/repos/view/repo_list_view_screen.dart';
import 'package:github_graphql_app/repos/view_modal/list_view_cubit.dart';
import 'package:github_graphql_app/repos/view_modal/search_view_cubit.dart';
import 'package:go_router/go_router.dart';

typedef SubPathRecord = ({String name, String path});

enum AppRouteConfig {
  splash(
    '/',
    name: 'splash',
  ),
  auth(
    '/auth',
    name: 'auth',
  ),
  welcome(
    '/welcome',
    name: 'welcome',
  ),
  repos(
    '/repos',
    name: 'repos',
  ),
  details(
    '/details/:repoName',
    name: 'details',
  );

  const AppRouteConfig(
    this.path, {
    required this.name,
  });

  final String path;
  final String name;

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'app');

  static const String detailsSubRouteName = 'repoDetails';

  static final List<RouteBase> _routes = values.map(
    (route) {
      return switch (route) {
        AppRouteConfig.repos => ShellRoute(
            builder: (context, state, child) {
              return ListenableBuilder(
                listenable: GraphQLConfig(),
                builder: (context, child) {
                  return GraphQLConfig().isInitialized
                      ? child!
                      : const Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                },
                child: RepositoryProvider<LoginUserStorage>(
                  create: (context) => LoginUserStorage(),
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<ListViewCubit>(
                        create: (context) => ListViewCubit(),
                      ),
                      BlocProvider(create: (context) => SearchViewCubit()),
                    ],
                    child: RepoListView.responsive(
                      context: context,
                      child: child,
                    ),
                  ),
                ),
              );
            },
            routes: [
              GoRoute(
                path: route.path,
                name: route.name,
                builder: (_, __) =>
                    const Center(child: Text('No repositories selected')),
                routes: [
                  GoRoute(
                    path: ':repoName',
                    name: detailsSubRouteName,
                    pageBuilder: (context, state) {
                      final repositoryName = state.pathParameters['repoName'];

                      if (repositoryName == null || repositoryName.isEmpty) {
                        throw Exception('Repository name is required');
                      }

                      return NoTransitionPage(
                        child: RepoDetailsView(repositoryName: repositoryName),
                      );
                    },
                  )
                ],
              )
            ],
          ),
        AppRouteConfig.splash => GoRoute(
            name: route.name,
            path: route.path,
            builder: (_, __) => const SplashScreen(),
          ),
        AppRouteConfig.auth => GoRoute(
            name: route.name,
            path: route.path,
            builder: (context, state) {
              if (state.extra is! AuthScreenRouteInfo) {
                assert(
                  state.extra is AuthScreenRouteInfo,
                  'Incorrect route data provided!',
                );

                return WelcomeScreenView.responsive(context);
              }

              final authScreenRouteInfo = state.extra as AuthScreenRouteInfo;

              return AuthScreen(
                authUrl: authScreenRouteInfo.authUri,
                onAuthCodeRedirectAttempt:
                    authScreenRouteInfo.onAuthCodeRedirectAttempt,
              );
            },
          ),
        AppRouteConfig.welcome => GoRoute(
            name: route.name,
            path: route.path,
            builder: (context, _) => WelcomeScreenView.responsive(context),
          ),
        AppRouteConfig.details => GoRoute(
            path: route.path,
            name: route.name,
            builder: (context, state) {
              final repositoryName = state.pathParameters['repoName'];

              if (repositoryName == null || repositoryName.isEmpty) {
                throw Exception('Repository name is required');
              }

              return RepoDetailsView(repositoryName: repositoryName);
            },
          ),
      };
    },
  ).toList();

  static GoRouter get router => GoRouter(
        navigatorKey: rootNavigatorKey,
        routes: _routes,
      );
}
