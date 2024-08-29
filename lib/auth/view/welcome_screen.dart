import 'dart:async';

import 'package:github_graphql_app/auth/modal/auth_screen_route_info.dart';
import 'package:github_graphql_app/auth/view_modal/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:github_graphql_app/core/routes/app_route.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.read<AuthBloc>().signIn(
              (authorizationUri) {
                final completer = Completer<Uri>();
                context.goNamed(
                  AppRoute.auth.name,
                  extra: AuthScreenRouteInfo(
                    authUri: authorizationUri,
                    onAuthCodeRedirectAttempt: (redirectedUrl) =>
                        completer.complete(redirectedUrl),
                  ),
                );
      
                return completer.future;
              },
            );
          },
          backgroundColor: const Color(0xFF55A247),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          label: const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        body: CustomScrollView(
          clipBehavior: Clip.antiAlias,
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              delegate: LoginSliverHeaderDelegate(),
              pinned: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const SizedBox(height: 24),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        text: 'Welcome !',
                        children: [
                          TextSpan(
                            text: '\nSign in to continue..',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 20 - (shrinkOffset * .025)),
          decoration: BoxDecoration(
            color: const Color(0xFF24292F),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(100),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[400]!,
                offset: const Offset(0, 2),
                blurRadius: 2,
              )
            ],
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/svgs/github.svg',
            theme: const SvgTheme(currentColor: Colors.white38),
            height: 100,
            width: 100,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          // Animation is functional but needs scroll effect to work
          // child: AnimatedContainer(
          child: Container(
            alignment: Alignment.center,
            // duration: const Duration(milliseconds: 200),
            height: 50,
            // - (shrinkOffset <= 40 ? shrinkOffset : 20),
            width: 250,
            //  - (shrinkOffset <= 50 ? shrinkOffset : 50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[500]!,
                  offset: const Offset(0, 2),
                  blurRadius: 3,
                )
              ],
            ),
            // child: AnimatedDefaultTextStyle(
            //   style: TextStyle(
            //     fontSize: 25 - (shrinkOffset * 0.04),
            //     color: Colors.black,
            //     fontWeight: FontWeight.w500,
            //   ),
            //   duration: const Duration(milliseconds: 100),
            //   curve: Curves.linear,
            child: const Text(
              'GitHub Client App',
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        // ),
      ],
    );
  }

  @override
  double get maxExtent => 250;

  @override
  double get minExtent => 200;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
