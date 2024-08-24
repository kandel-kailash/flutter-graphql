import 'package:github_graphql_app/auth/modal/auth_state.dart';
import 'package:github_graphql_app/auth/view_modal/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// The Widget that configures your application.
class AppWidget extends StatelessWidget {
  const AppWidget({
    super.key,
    required this.appRouter,
  });

  final GoRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeMap(
          orElse: () {},
          authenticated: (_) => appRouter.go('/repos'),
          unauthenticated: (_) => appRouter.go('/login'),
        );
      },
      child: MaterialApp.router(
        // Remove debug banner
        debugShowCheckedModeBanner: false,

        restorationScopeId: 'app',

        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [
          Locale('en', ''), // English, no country code
        ],

        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)!.appTitle,

        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        routerConfig: appRouter,
      ),
    );
  }
}
