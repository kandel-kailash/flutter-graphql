import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:github_graphql_app/src/app_wrapper.dart';
import 'package:go_router/go_router.dart';

/// The Widget that configures your application.
class Root extends StatelessWidget {
  const Root({
    super.key,
    required this.appRouter,
  });

  final GoRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      routerConfig: appRouter,
      restorationScopeId: 'app',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      builder: (context, child) {
        final navigatorChild = ArgumentError.checkNotNull(child, 'child');

        return AppWrapper(
          appRouter: appRouter,
          child: navigatorChild,
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
