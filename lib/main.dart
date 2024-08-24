import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:github_graphql_app/auth/modal/auth_screen_route_info.dart';
import 'package:github_graphql_app/auth/services/authentication/github_authenticator.dart';
import 'package:github_graphql_app/auth/services/credentials_storage/credentials_storage.dart';
import 'package:github_graphql_app/auth/services/credentials_storage/secure_credentials_storage.dart';
import 'package:github_graphql_app/auth/view/auth_screen.dart';
import 'package:github_graphql_app/auth/view/login_screen.dart';
import 'package:github_graphql_app/auth/view_modal/auth_cubit.dart';
import 'package:github_graphql_app/core/views/splash_screen.dart';
import 'package:github_graphql_app/home/view/repo_list_screen.dart';
import 'package:go_router/go_router.dart';

import 'src/app.dart';

void main() async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) {
          if (state.extra is! AuthScreenRouteInfo) {
            assert(state.extra is AuthScreenRouteInfo,
                'Incorrect route data provided!');
            return const LoginScreen();
          }

          final authScreenRouteInfo = state.extra as AuthScreenRouteInfo;

          return AuthScreen(
            authUrl: authScreenRouteInfo.authUri,
            onAuthCodeRedirectAttempt:
                authScreenRouteInfo.onAuthCodeRedirectAttempt,
          );
        },
      ),
      GoRoute(
        path: '/repos',
        builder: (context, state) => const RepoListScreen(),
      )
    ],
  );
  const securedStorage = FlutterSecureStorage();

  // Run the app.
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => Dio(),
        ),
        RepositoryProvider<CredentialsStorage>(
          create: (context) => SecureCredentialStorage(securedStorage),
        ),
        RepositoryProvider(
          create: (context) => GithubAuthenticator(
            context.read<CredentialsStorage>(),
            context.read<Dio>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              context.read<GithubAuthenticator>(),
            ),
          ),
        ],
        child: AppWidget(appRouter: router),
      ),
    ),
  );
}
