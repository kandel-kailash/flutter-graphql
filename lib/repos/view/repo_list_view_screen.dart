import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_graphql_app/core/routes/app_route_config.dart';
import 'package:github_graphql_app/core/shared/enums/screen_width.dart';
import 'package:github_graphql_app/core/views/responsive_view.dart';
import 'package:github_graphql_app/repos/model/github_repository/github_repository.dart';
import 'package:github_graphql_app/repos/model/state/list_view_state.dart';
import 'package:github_graphql_app/repos/view/widgets/custom_app_bar.dart';
import 'package:github_graphql_app/repos/view/widgets/repo_tile.dart';
import 'package:github_graphql_app/repos/view_modal/list_view_cubit.dart';
import 'package:go_router/go_router.dart';

sealed class RepoListView extends StatelessWidget implements ResponsiveView {
  const RepoListView({super.key});

  @override
  factory RepoListView.responsive({
    required BuildContext context,
    required Widget child,
  }) {
    return switch (ScreenWidth.from(context)) {
      ScreenWidth.phone => const _RepoListPortraitView(),
      ScreenWidth.tablet => _RepoListTabletView(child: child),
      ScreenWidth.desktop => throw UnimplementedError(),
    };
  }
}

class _RepoListPortraitView extends RepoListView {
  const _RepoListPortraitView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const SliverAppBar(
              pinned: true,
              elevation: 2,
              expandedHeight: 100,
              collapsedHeight: 100,
              flexibleSpace: CustomAppBar(),
            ),
            SliverPersistentHeader(
              delegate: _ListTitlePersistentHeaderDelegate(),
            ),
          ];
        },
        body: _RepoListView(
          onTapRepoItem: (repo) => context.goNamed(
            AppRouteConfig.details.name,
            pathParameters: {'repoName': repo.name},
          ),
        ),
      ),
    );
  }
}

class _ListTitlePersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      const Material(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: _ListTitle(),
        ),
      );

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _RepoListTabletView extends RepoListView {
  const _RepoListTabletView({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return switch (orientation) {
          Orientation.portrait => const _RepoListPortraitView(),
          Orientation.landscape => _RepoListLandscapeView(child: child),
        };
      },
    );
  }
}

class _RepoListLandscapeView extends StatefulWidget {
  const _RepoListLandscapeView({required this.child});

  final Widget child;

  @override
  State<_RepoListLandscapeView> createState() => _RepoListLandscapeViewState();
}

class _RepoListLandscapeViewState extends State<_RepoListLandscapeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        physics: const NeverScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const SliverAppBar(
              collapsedHeight: 100,
              expandedHeight: 100,
              pinned: true,
              elevation: 2,
              flexibleSpace: CustomAppBar(),
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            spacing: 12,
            children: [
              Drawer(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                width: MediaQuery.of(context).size.width * 0.4,
                child: NestedScrollView(
                  // Adding a scroll controller to avoid StackOverflow error
                  controller: ScrollController(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    const SliverResizingHeader(child: _ListTitle()),
                  ],
                  body: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _RepoListView(
                      onTapRepoItem: (repo) => context.goNamed(
                        AppRouteConfig.detailsSubRouteName,
                        pathParameters: {'repoName': repo.name},
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepoListView extends StatefulWidget {
  const _RepoListView({required this.onTapRepoItem});

  final ValueChanged<GithubRepository> onTapRepoItem;

  @override
  State<_RepoListView> createState() => _RepoListViewState();
}

class _RepoListViewState extends State<_RepoListView> {
  late final ScrollController _listViewScrollController = ScrollController()
    ..addListener(
      () {
        if (_listViewScrollController.position.pixels >=
            _listViewScrollController.position.maxScrollExtent * 0.67) {
          context.read<ListViewCubit>().onScroll();
        }
      },
    );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListViewCubit, ListViewState>(
      builder: (context, state) {
        final repos = context.watch<ListViewCubit>().repos;

        final isLoading = switch (state) {
          Loading() => true,
          _ => false,
        };

        final itemCount = repos.length + (isLoading ? 1 : 0);

        return ListView.builder(
          itemCount: itemCount,
          controller: _listViewScrollController,
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          itemBuilder: (context, index) {
            if (isLoading && index == 0) {
              return const LinearProgressIndicator();
            }

            final repo = repos.elementAt(index - (isLoading ? 1 : 0));

            return RepoTile(
              repo: repo,
              onTap: widget.onTapRepoItem,
            );
          },
        );
      },
    );
  }
}

class _ListTitle extends StatefulWidget {
  const _ListTitle();

  @override
  State<_ListTitle> createState() => _ListTitleState();
}

// class _ListTitleState extends State<_ListTitle>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat(reverse: true);
//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Theme.of(context).colorScheme.surfaceDim,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//           vertical: 0,
//           horizontal: 24,
//         ),
//         child: FadeTransition(
//           opacity: _animation,
//           child: const Text(
//             'Repositories',
//             style: TextStyle(
//               fontSize: 32,
//               shadows: [
//                 Shadow(
//                   color: Colors.blueGrey,
//                   offset: Offset(-1, -1),
//                 )
//               ],
//               color: Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class _ListTitleState extends State<_ListTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _characterAnimations;

  final String _titleText = 'Repositories';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Create an animation for each character
    _characterAnimations = List.generate(
      _titleText.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            // Stagger the animations
            index * (1 / _titleText.length),
            (index + 1) * (1 / _titleText.length),
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceDim,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 24,
        ),
        child: Row(
          children: List.generate(
            _titleText.length,
            (index) => FadeTransition(
              opacity: _characterAnimations[index],
              child: Text(
                _titleText[index],
                style: const TextStyle(
                  fontSize: 32,
                  shadows: [
                    Shadow(
                      color: Colors.blueGrey,
                      offset: Offset(-1, -1),
                    )
                  ],
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
