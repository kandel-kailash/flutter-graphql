import 'package:flutter/material.dart';
import 'package:github_graphql_app/core/routes/app_route_config.dart';
import 'package:github_graphql_app/src/root.dart';

void main() => runApp(Root(appRouter: AppRouteConfig.router));
