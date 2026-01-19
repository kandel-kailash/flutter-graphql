import 'package:flutter/material.dart';
import 'package:github_graphql_app/src/auth/view/widgets/github_logo.dart';
import 'package:github_graphql_app/core/theme/default_colors.dart';

class WelcomeScreenHeader extends SliverPersistentHeader {
  WelcomeScreenHeader({
    super.key,
    required this.maxExtent,
    required this.minExtent,
  }) : super(
         delegate: _WelcomeSliverHeaderDelegate(
           maxExtent: maxExtent,
           minExtent: minExtent,
         ),
         pinned: true,
       );

  final double maxExtent;
  final double minExtent;
}

class _WelcomeSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _WelcomeSliverHeaderDelegate({
    required this.maxExtent,
    required this.minExtent,
  });

  @override
  final double maxExtent;

  @override
  final double minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _WelcomePersistentHeader(maxExtent: maxExtent);
  }

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
    _controller.addListener(() {
      if (_textContainerAlignment != Alignment.bottomCenter) {
        setState(() => _textContainerAlignment = Alignment.bottomCenter);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              color: gitHubLogoColor,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(value * 100),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[400]!,
                  offset: const Offset(0, 2),
                  blurRadius: 2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const GithubLogo(size: Size(120, 120)),
          ),
        ),
        FadeTransition(
          opacity: CurvedAnimation(parent: _controller, curve: Curves.linear),
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
                  ),
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
