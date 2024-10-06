import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_graphql_app/auth/view_modal/auth_cubit.dart';
import 'package:github_graphql_app/repos/model/user/user.dart';

class CustomAppBar extends StatelessWidget {
  final User? user;

  

  const CustomAppBar({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 60, top: 10),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[400]!,
                  offset: const Offset(2, 2),
                  blurRadius: 2,
                ),
              ],
            ),
            child: user == null
                ? const _AppBarContent()
                : _AppBarContent(
                    name: user?.name,
                  ),
          ),
          user == null
              ? const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person),
                )
              : CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user!.avatarUrl),
                )
        ],
      ),
    );
  }
}

class _AppBarContent extends StatelessWidget {
  final String? name;

  const _AppBarContent({this.name});

  @override
  Widget build(BuildContext context) {
    return Ink(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 20),
          Text(
            name ?? '...',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
    );
  }
}
