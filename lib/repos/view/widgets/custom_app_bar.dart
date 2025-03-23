import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_graphql_app/auth/view_modal/auth_cubit.dart';
import 'package:github_graphql_app/core/routes/app_route_config.dart';
import 'package:github_graphql_app/repos/model/state/list_view_state.dart';
import 'package:github_graphql_app/repos/model/state/search_view_result.dart';
import 'package:github_graphql_app/repos/model/state/search_view_state.dart';
import 'package:github_graphql_app/repos/model/user/user.dart';
import 'package:github_graphql_app/repos/view_modal/list_view_cubit.dart';
import 'package:github_graphql_app/repos/view_modal/search_view_cubit.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends PreferredSize {
  const CustomAppBar({
    super.key,
  }) : super(
          preferredSize: const Size.fromHeight(double.maxFinite),
          child: const _CustomAppBarWidget(),
        );
}

class _CustomAppBarWidget extends StatefulWidget {
  const _CustomAppBarWidget();

  @override
  State<_CustomAppBarWidget> createState() => _CustomAppBarWidgetState();
}

class _CustomAppBarWidgetState extends State<_CustomAppBarWidget> {
  final SearchController _searchController = SearchController();

  void _onTapSearch() {
    showDialog(
      context: context,
      builder: (_) {
        List<Widget> suggestions = [];

        return Dialog(
          child: BlocBuilder<SearchViewCubit, SearchViewState>(
            bloc: context.read<SearchViewCubit>(),
            builder: (_, state) {
              switch (state) {
                case SearchViewLoadingState():
                  suggestions = [
                    const LinearProgressIndicator(),
                    ...suggestions,
                  ];

                case SearchViewLoadedState(:List<SearchViewResult> result):
                  result.removeWhere((e) => e.loginName.isEmpty);

                  suggestions
                    ..clear()
                    ..addAll(
                      result.map(
                        (searchViewResult) => ListTile(
                          title: Text(searchViewResult.name),
                          onTap: () {
                            context.read<ListViewCubit>().fetchUserData(
                                  User.fromSearchViewResult(searchViewResult),
                                );

                            _searchController.text = '';
                            _searchController.closeView(searchViewResult.name);

                            Navigator.of(context).pop();
                            context.goNamed(AppRouteConfig.repos.name);
                            // SearchAnchor.
                          },
                        ),
                      ),
                    );

                default:
              }

              return SearchAnchor.bar(
                onChanged: context.read<SearchViewCubit>().searchUser,
                viewLeading: const BackButton(),
                barHintText: 'Search users',
                isFullScreen: false,
                viewHintText: 'Search users',
                searchController: _searchController,
                suggestionsBuilder: (_, __) async => suggestions,
                textInputAction: TextInputAction.done,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: TweenAnimationBuilder(
          tween: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (_, opacity, child) {
            return Opacity(
              opacity: opacity,
              child: child,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 20,
            children: [
              Expanded(
                child: BlocBuilder<ListViewCubit, ListViewState>(
                  builder: (context, state) {
                    User? currentUser = ListViewCubit.currentOwner;

                    if (state case Loaded(:User user)) {
                      if (currentUser != user) {
                        currentUser = user;
                      }
                    }

                    return Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 60,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            padding: const EdgeInsets.only(
                              left: 40,
                              right: 20,
                            ),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(4, 4),
                                  color: Colors.grey[350]!,
                                  blurRadius: 8,
                                ),
                              ],
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    currentUser?.name ?? '',
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _onTapSearch,
                                  icon: const Icon(Icons.search),
                                ),
                              ],
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: currentUser == null
                              ? null
                              : NetworkImage(currentUser.avatarUrl),
                          child: currentUser != null
                              ? null
                              : const Icon(Icons.person),
                        ),
                      ],
                    );
                  },
                ),
              ),
              _MenuContainer(
                child: Row(
                  spacing: 16,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings),
                    ),
                    IconButton(
                      tooltip: 'Sign out',
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const SimpleDialog(
                              children: [
                                SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('Signing out...'),
                              ],
                            );
                          },
                        );

                        await context.read<AuthCubit>().signOut();
                      },
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuContainer extends StatelessWidget {
  const _MenuContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            offset: const Offset(4, 4),
            color: Colors.grey[350]!,
            blurRadius: 8,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: child,
    );
  }
}
