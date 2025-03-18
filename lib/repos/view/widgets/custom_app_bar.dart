import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_graphql_app/auth/view_modal/auth_cubit.dart';
import 'package:github_graphql_app/repos/model/state/list_view_state.dart';
import 'package:github_graphql_app/repos/model/state/search_view_result.dart';
import 'package:github_graphql_app/repos/model/state/search_view_state.dart';
import 'package:github_graphql_app/repos/model/user/user.dart';
import 'package:github_graphql_app/repos/view_modal/list_view_cubit.dart';
import 'package:github_graphql_app/repos/view_modal/search_view_cubit.dart';

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

  void _onTap() {
    showDialog(
      context: context,
      builder: (_) {
        final List<Widget> suggestions = [];

        return Dialog(
          child: BlocBuilder<SearchViewCubit, SearchViewState>(
            bloc: context.read<SearchViewCubit>(),
            builder: (_, state) {
              switch (state) {
                case SearchViewLoadingState():
                  Widget? lastSuggestion;

                  try {
                    suggestions.asMap().forEach((index, widget) {
                      final nextSuggestion = suggestions[index + 1];

                      if (index == 0) {
                        lastSuggestion = suggestions[0];
                        suggestions[0] = const LinearProgressIndicator();
                        suggestions[1] = lastSuggestion!;

                        lastSuggestion = nextSuggestion;

                        return;
                      }

                      suggestions[index + 1] = lastSuggestion!;
                      lastSuggestion = nextSuggestion;

                      return;
                    });
                    // TODO @kailash: Is this a valid solution?
                  } on RangeError catch (error, stackTrace) {
                    debugPrintStack(
                      stackTrace: stackTrace,
                      label: 'CustomAppBar < Line 144 >: $error',
                    );

                    if (lastSuggestion != null) {
                      suggestions.add(lastSuggestion!);
                    }
                  }

                case SearchViewLoadedState(:List<SearchViewResult> result):
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

                            Navigator.of(context).pop();

                            _searchController.text = '';
                            _searchController.closeView(searchViewResult.name);
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          Positioned(
            left: 40,
            right: 0,
            child: SearchBar(
              onTap: _onTap,
              padding: const WidgetStatePropertyAll(
                EdgeInsets.only(left: 40, right: 20),
              ),
              hintText: 'Search users',
              trailing: [
                const SizedBox(width: 8),
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
          ),
          BlocBuilder<ListViewCubit, ListViewState>(
            builder: (context, state) {
              User? currentUser = ListViewCubit.currentOwner;

              if (state case Loaded(:User user)) {
                if (currentUser != user) {
                  currentUser = user;
                }
              }

              return CircleAvatar(
                radius: 40,
                backgroundImage: currentUser == null
                    ? null
                    : NetworkImage(currentUser.avatarUrl),
                child: currentUser != null ? null : const Icon(Icons.person),
              );
            },
          )
        ],
      ),
    );
  }
}
