import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:github_graphql_app/auth/modal/auth_state.dart';
import 'package:github_graphql_app/auth/services/authentication/github_authenticator.dart';
import 'package:github_graphql_app/auth/services/credentials_storage/credentials_storage.dart';
import 'package:github_graphql_app/auth/services/credentials_storage/secure_credentials_storage.dart';
import 'package:github_graphql_app/auth/view_modal/auth_cubit.dart';
import 'package:github_graphql_app/core/routes/app_route_config.dart';
import 'package:go_router/go_router.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({
    super.key,
    required this.child,
    required this.appRouter,
  });

  final Widget child;
  final GoRouter appRouter;

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isStartUp = true;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => Dio(),
        ),
        RepositoryProvider<CredentialsStorage>(
          create: (context) =>
              SecureCredentialStorage(const FlutterSecureStorage()),
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
            create: (context) => AuthBloc(context.read<GithubAuthenticator>()),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (_, state) {
            state.maybeMap(
              orElse: () {},
              authenticated: (_) =>
                  widget.appRouter.goNamed(AppRouteConfig.repos.name),
              unauthenticated: (_) async {
                // Delaying to show to the splash screen
                if (_isStartUp) {
                  await Future.delayed(const Duration(seconds: 2));
                  // Set it to false for the rest of the session
                  _isStartUp = false;
                }

                widget.appRouter.goNamed(AppRouteConfig.welcome.name);
              },
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
