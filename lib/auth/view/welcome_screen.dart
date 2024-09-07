import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:github_graphql_app/auth/modal/auth_screen_route_info.dart';
import 'package:github_graphql_app/auth/view_modal/auth_cubit.dart';
import 'package:github_graphql_app/core/routes/app_route_config.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
                  AppRouteConfig.auth.name,
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
              delegate: _WelcomeSliverHeaderDelegate(),
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
                            text: '\nPlease sign in to continue..',
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

class _WelcomeSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _WelcomePersistentHeader(maxExtent: maxExtent);
  }

  @override
  double get maxExtent => 250;

  @override
  double get minExtent => 200;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _WelcomePersistentHeader extends StatefulWidget {
  const _WelcomePersistentHeader({required this.maxExtent});

  final double maxExtent;

  @override
  State<_WelcomePersistentHeader> createState() =>
      _WelcomePersistentHeaderState();
}

class _WelcomePersistentHeaderState extends State<_WelcomePersistentHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  AlignmentGeometry _textContainerAlignment = Alignment.topCenter;

  @override
  void initState() {
    super.initState();

    _controller.forward();
    _controller.addListener(
      () {
        if (_textContainerAlignment != Alignment.bottomCenter) {
          setState(() => _textContainerAlignment = Alignment.bottomCenter);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: _controller,
          builder: (_, value, __) => AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: value * widget.maxExtent,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF24292F),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(value * 100),
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
              'assets/svgs/github-logo.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              height: 100,
              width: 100,
            ),
          ),
        ),
        FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Curves.linear,
          ),
          child: AnimatedAlign(
            curve: Curves.linearToEaseOut,
            duration: const Duration(seconds: 1),
            alignment: _textContainerAlignment,
            child: Container(
              alignment: Alignment.center,
              height: 50,
              width: 250,
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
        ),
      ],
    );
  }
}
