class AuthScreenRouteInfo {
  AuthScreenRouteInfo({
    required this.authUri,
    required this.onAuthCodeRedirectAttempt,
  });
  
  final Uri authUri;
  final void Function(Uri authUri) onAuthCodeRedirectAttempt;
}
