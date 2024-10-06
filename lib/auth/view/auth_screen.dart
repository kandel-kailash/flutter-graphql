import 'package:flutter/material.dart';
import 'package:github_graphql_app/core/constants/urls.dart';
import 'package:github_graphql_app/core/routes/app_route_config.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthScreen extends StatelessWidget {
  final Uri authUrl;
  final void Function(Uri redirectUrl) onAuthCodeRedirectAttempt;

  const AuthScreen({
    super.key,
    required this.authUrl,
    required this.onAuthCodeRedirectAttempt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        leading: BackButton(
          onPressed: () => context.goNamed(AppRouteConfig.welcome.name),
        ),
        title: const Text('Github Auth'),
      ),
      body: AuthBody(
        authUrl: authUrl,
        onAuthCodeRedirectAttempt: onAuthCodeRedirectAttempt,
      ),
    );
  }
}

class AuthBody extends StatelessWidget {
  const AuthBody({
    super.key,
    required this.authUrl,
    required this.onAuthCodeRedirectAttempt,
  });

  final Uri authUrl;
  final void Function(Uri redirectUrl) onAuthCodeRedirectAttempt;

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: WebViewController()
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) {
              final currentUrl = request.url;
              if (!currentUrl.contains(redirectUrl)) {
                return NavigationDecision.navigate;
              }

              onAuthCodeRedirectAttempt(Uri.parse(currentUrl));
              return NavigationDecision.prevent;
            },
          ),
        )
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(
          authUrl,
        ),
    );
  }
}
