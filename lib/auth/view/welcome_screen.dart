import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_graphql_app/auth/modal/auth_screen_route_info.dart';
import 'package:github_graphql_app/auth/view/widgets/github_logo.dart';
import 'package:github_graphql_app/auth/view/widgets/welcome_screen_header.dart';
import 'package:github_graphql_app/auth/view_modal/auth_cubit.dart';
import 'package:github_graphql_app/core/routes/app_route_config.dart';
import 'package:github_graphql_app/core/shared/enums/device_type.dart';
import 'package:github_graphql_app/core/shared/enums/screen_width.dart';
import 'package:github_graphql_app/core/theme/default_colors.dart';
import 'package:github_graphql_app/core/views/responsive_view.dart';
import 'package:go_router/go_router.dart';

sealed class WelcomeScreenView extends StatelessWidget
    implements ResponsiveView {
  const WelcomeScreenView({super.key});

  @override
  factory WelcomeScreenView.responsive(BuildContext context) {
    if (!kIsWeb) {
      if (DeviceType.isMobile) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    }

    return switch (ScreenWidth.from(context)) {
      ScreenWidth.phone => const _WelcomeScreenPortraitView(),
      ScreenWidth.tablet => const _WelcomeScreenTabletView(),
      ScreenWidth.desktop => throw UnimplementedError(),
    };
  }
}

class _WelcomeScreenPortraitView extends WelcomeScreenView {
  const _WelcomeScreenPortraitView();

  @override
  Widget build(BuildContext context) {
    final ScreenWidth screenType = ScreenWidth.from(context);

    return Scaffold(
      body: CustomScrollView(
        clipBehavior: Clip.antiAlias,
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          WelcomeScreenHeader(
            maxExtent: screenType == ScreenWidth.phone ? 300 : 400,
            minExtent: screenType == ScreenWidth.phone ? 300 : 400,
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 24),
            sliver: SliverToBoxAdapter(
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  text: 'Welcome !',
                  children: [
                    TextSpan(
                      text: '\nPlease sign in to continue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: _SignInButton(),
            ),
          )
        ],
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        context.read<AuthCubit>().signIn(
          (authorizationUri) {
            final completer = Completer<Uri>();

            if (kIsWeb) {
              // TODO @kailash: Open the auth in a new tab for web
            } else {
              context.goNamed(
                AppRouteConfig.auth.name,
                extra: AuthScreenRouteInfo(
                  authUri: authorizationUri,
                  onAuthCodeRedirectAttempt: (redirectedUrl) =>
                      completer.complete(redirectedUrl),
                ),
              );
            }

            return completer.future;
          },
        );
      },
      icon: const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: GithubLogo(
          size: Size(24, 24),
          colorFilter: ColorFilter.mode(
            gitHubLogoColor,
            BlendMode.srcIn,
          ),
        ),
      ),
      label: const Text('Sign in using GitHub'),
    );
  }
}

class _WelcomeScreenTabletView extends WelcomeScreenView {
  const _WelcomeScreenTabletView();

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        switch (orientation) {
          case Orientation.portrait:
            return const _WelcomeScreenPortraitView();
          case Orientation.landscape:
            final MediaQueryData mediaQuery = MediaQuery.of(context);

            return _WelcomeScreenLandscapeView(mediaQuery: mediaQuery);
        }
      },
    );
  }
}

class _WelcomeScreenLandscapeView extends StatefulWidget {
  const _WelcomeScreenLandscapeView({required this.mediaQuery});

  final MediaQueryData mediaQuery;

  @override
  State<_WelcomeScreenLandscapeView> createState() =>
      _WelcomeScreenLandscapeViewState();
}

class _WelcomeScreenLandscapeViewState
    extends State<_WelcomeScreenLandscapeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )
    ..forward()
    ..addListener(
      () => setState(() {}),
    )
    ..addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          setState(() => _radius = 50);
        case AnimationStatus.dismissed:
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
      }
    });

  double _radius = double.maxFinite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 1),
          opacity: _controller.value,
          child: AnimatedContainer(
            duration: _controller.duration!,
            curve: Curves.easeInOutCubic,
            width: _controller.value * 0.75 * widget.mediaQuery.size.width,
            height: _controller.value * 0.75 * widget.mediaQuery.size.height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border.all(
                color: gitHubLogoColor,
                width: .1,
              ),
              borderRadius: BorderRadius.circular(_radius),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(4, 4),
                  color: Colors.grey[350]!,
                  blurRadius: 5,
                ),
                const BoxShadow(
                  color: Colors.black38,
                  blurRadius: .2,
                ),
              ],
            ),
            child: Center(
              child: Stack(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _AnimatedGithubLogo(),
                      ),
                      Expanded(
                        child: Center(child: _SignInButton()),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(4, 4),
                            color: Colors.black26,
                            blurRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: .2,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Github Client App',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedGithubLogo extends StatefulWidget {
  const _AnimatedGithubLogo();

  @override
  State<_AnimatedGithubLogo> createState() => _AnimatedGithubLogoState();
}

class _AnimatedGithubLogoState extends State<_AnimatedGithubLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )
    ..forward()
    ..addStatusListener(
      (status) {
        switch (status) {
          case AnimationStatus.completed:
            setState(
              () => _containerShape = const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
              ),
            );
          case AnimationStatus.forward:
          case AnimationStatus.reverse:
          case AnimationStatus.dismissed:
            setState(() {});
        }
      },
    );

  late ShapeBorder _containerShape = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _controller.duration!,
      decoration: ShapeDecoration(
        color: gitHubLogoColor,
        shape: _containerShape,
      ),
      child: AnimatedFractionallySizedBox(
        duration: _controller.duration!,
        heightFactor: _controller.value,
        widthFactor: _controller.value,
        child: AnimatedPadding(
          duration: _controller.duration!,
          padding: EdgeInsets.all(
            (_controller.value * 60) + 40,
          ),
          child: AnimatedOpacity(
            duration: _controller.duration!,
            opacity: _controller.value,
            child: const GithubLogo(
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}
