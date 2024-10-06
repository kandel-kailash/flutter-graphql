import 'package:github_graphql_app/auth/modal/auth_screen_route_info.dart';
import 'package:github_graphql_app/auth/view/auth_screen.dart';
import 'package:github_graphql_app/auth/view/welcome_screen.dart';
import 'package:github_graphql_app/core/views/splash_screen.dart';
import 'package:github_graphql_app/repos/view/repo_list_screen.dart';
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

  GoRouterWidgetBuilder get _builder {
    return (context, state) {
      return switch (this) {
        AppRouteConfig.splash => const SplashScreen(),
        AppRouteConfig.auth => () {
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
          }(),
        AppRouteConfig.welcome => WelcomeScreenView.responsive(context),
        AppRouteConfig.repos => RepoListView.responsive(context),
      };
    };
  }

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
