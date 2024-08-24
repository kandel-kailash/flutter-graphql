import 'package:github_graphql_app/auth/services/authentication/github_authenticator.dart';
import 'package:github_graphql_app/home/model/home_state/home_state.dart';
import 'package:github_graphql_app/home/services/graphql_config.dart';
import 'package:github_graphql_app/home/view/widgets/repo_tile.dart';
import 'package:github_graphql_app/home/view/widgets/custom_app_bar.dart';
import 'package:github_graphql_app/home/view_modal/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RepoListScreen extends StatelessWidget {
  const RepoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        GraphQLConfig(context.read<GithubAuthenticator>()),
      ),
      child: Builder(
        builder: (context) {
          return SafeArea(
            child: Scaffold(
              extendBodyBehindAppBar: true,
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.search_rounded),
              ),
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(double.maxFinite),
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      orElse: () {
                        return const CustomAppBar();
                      },
                      loaded: (user, _) {
                        return CustomAppBar(user: user);
                      },
                    );
                  },
                ),
              ),
              body: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    orElse: () {
                      return const Center(
                        child: Text('No repos'),
                      );
                    },
                    loaded: (_, repos) {
                      return NotificationListener<ScrollNotification>(
                        onNotification: context.read<HomeCubit>().onScroll,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 90, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  top: 10,
                                ),
                                child: Text(
                                  'Repositories',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontStyle: FontStyle.italic,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.blueGrey,
                                        offset: Offset(0, -5),
                                      )
                                    ],
                                    color: Colors.transparent,
                                    decoration: TextDecoration.combine(
                                      [
                                        TextDecoration.underline,
                                        TextDecoration.underline,
                                      ],
                                    ),
                                    decorationColor: Colors.deepPurpleAccent,
                                    decorationThickness: 2,
                                    decorationStyle: TextDecorationStyle.wavy,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...List.generate(
                                repos.length + 2,
                                (index) {
                                  return (index < repos.length)
                                      ? RepoTile(
                                          repo: repos[index],
                                        )
                                      : Container();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
