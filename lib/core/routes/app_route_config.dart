import 'package:github_graphql_app/auth/modal/auth_screen_route_info.dart';
import 'package:github_graphql_app/auth/view/auth_screen.dart';
import 'package:github_graphql_app/auth/view/welcome_screen.dart';
import 'package:github_graphql_app/core/views/splash_screen.dart';
import 'package:github_graphql_app/home/view/repo_list_screen.dart';
import 'package:go_router/go_router.dart';

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
  );

  const AppRouteConfig(
    this._path, {
    required this.name,
  });

  final String _path;
  final String name;

  GoRouterWidgetBuilder get _builder => switch (this) {
        AppRouteConfig.splash => (context, state) => const SplashScreen(),
        AppRouteConfig.auth => (context, state) {
            if (state.extra is! AuthScreenRouteInfo) {
              assert(
                state.extra is AuthScreenRouteInfo,
                'Incorrect route data provided!',
              );
              return const WelcomeScreen();
            }

            final authScreenRouteInfo = state.extra as AuthScreenRouteInfo;

            return AuthScreen(
              authUrl: authScreenRouteInfo.authUri,
              onAuthCodeRedirectAttempt:
                  authScreenRouteInfo.onAuthCodeRedirectAttempt,
            );
          },
        AppRouteConfig.welcome => (context, state) => const WelcomeScreen(),
        AppRouteConfig.repos => (context, state) => const RepoListScreen(),
      };

  static GoRouter get router => GoRouter(
        routes: values
            .map((route) => GoRoute(
                  path: route._path,
                  name: route.name,
                  builder: route._builder,
                ))
            .toList(),
      );
}
