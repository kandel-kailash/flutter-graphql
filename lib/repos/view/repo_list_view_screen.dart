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
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: _RepoListView(
          onTapRepoItem: (repo) => context.goNamed(
            AppRouteConfig.details.name,
            pathParameters: {'repoName': repo.name},
          ),
        ),
      ),
    );
  }
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

class _RepoListLandscapeView extends StatelessWidget {
  const _RepoListLandscapeView({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: Row(
          spacing: 12,
          children: [
            TweenAnimationBuilder(
              tween: Tween<Offset>(
                begin: const Offset(-200, 0),
                end: Offset.zero,
              ),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              builder: (_, offset, child) {
                return Transform.translate(
                  offset: offset,
                  child: child,
                );
              },
              child: Drawer(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                width: MediaQuery.of(context).size.width * 0.4,
                child: _RepoListView(
                  onTapRepoItem: (repo) => context.goNamed(
                    AppRouteConfig.detailsSubRouteName,
                    pathParameters: {'repoName': repo.name},
                  ),
                ),
              ),
            ),
            Expanded(child: child),
          ],
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

  int get _selectedRepoIndex => context.read<ListViewCubit>().selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ListTitle(),
        Expanded(
          child: BlocBuilder<ListViewCubit, ListViewState>(
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
                  horizontal: 8,
                ),
                itemBuilder: (context, index) {
                  if (isLoading && index == 0) {
                    return const LinearProgressIndicator();
                  }

                  final repo = repos.elementAt(index - (isLoading ? 1 : 0));

                  return RepoTile(
                    repo: repo,
                    onTap: (repo) {
                      context.read<ListViewCubit>().selectRepo(index);
                      widget.onTapRepoItem(repo);
                    },
                    isSelected: index == _selectedRepoIndex,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ListTitle extends StatefulWidget {
  const _ListTitle();

  @override
  State<_ListTitle> createState() => _ListTitleState();
}

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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceDim,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
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
    );
  }
}
