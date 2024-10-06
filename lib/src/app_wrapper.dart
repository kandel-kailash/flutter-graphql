import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:github_graphql_app/auth/modal/auth_state.dart';
import 'package:github_graphql_app/auth/services/authentication/github_authenticator.dart';
import 'package:github_graphql_app/auth/services/credentials_storage/credentials_storage.dart';
import 'package:github_graphql_app/auth/services/credentials_storage/secure_credentials_storage.dart';
import 'package:github_graphql_app/auth/view_modal/auth_cubit.dart';
import 'package:github_graphql_app/core/routes/app_route_config.dart';
import 'package:github_graphql_app/core/shared/screen_width.dart';
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

class _AppWrapperState extends State<AppWrapper> with WidgetsBindingObserver {
  late FlutterView? _view;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _view = View.maybeOf(context);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final Display? display = _view?.display;

    if (display == null) return;

    final double logicalWidth = display.size.width / display.devicePixelRatio;

    if (logicalWidth < ScreenWidth.phone.maxWidth) {
      SystemChrome.setPreferredOrientations(
        <DeviceOrientation>[DeviceOrientation.portraitUp],
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _view = null;
    super.dispose();
  }

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
            create: (context) => AuthCubit(context.read<GithubAuthenticator>()),
          ),
        ],
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            state.maybeMap(
              authenticated: (_) =>
                  widget.appRouter.goNamed(AppRouteConfig.repos.name),
              unauthenticated: (_) async {
                // Delaying to show to the splash screen
                if (context.read<AuthCubit>().isStartUp) {
                  // Set it to false for the rest of the session
                  context.read<AuthCubit>().isStartUp = false;
                  // Adding an arbitrary delay for the splash screen to last
                  await Future.delayed(const Duration(seconds: 2));
                }

                widget.appRouter.goNamed(AppRouteConfig.welcome.name);
              },
              orElse: () {
                // TODO @kailash: Navigate to a 404 page
              },
            );
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              context.read<AuthCubit>().checkAndUpdateAuthStatus();

              return SafeArea(child: widget.child);
            },
          ),
        ),
      ),
    );
  }
}
