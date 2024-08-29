import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:github_graphql_app/auth/services/authentication/github_authenticator.dart';
import 'package:github_graphql_app/auth/services/credentials_storage/credentials_storage.dart';
import 'package:github_graphql_app/auth/services/credentials_storage/secure_credentials_storage.dart';
import 'package:github_graphql_app/auth/view_modal/auth_cubit.dart';
import 'package:github_graphql_app/core/routes/app_route.dart';

import 'src/app.dart';

void main() async {
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
        child: AppWidget(appRouter: AppRoute.router),
      ),
    ),
  );
}
