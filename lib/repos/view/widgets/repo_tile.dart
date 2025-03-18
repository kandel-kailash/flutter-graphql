import 'package:flutter/material.dart';
import 'package:github_graphql_app/repos/model/github_repository/github_repository.dart';

class RepoTile extends StatelessWidget {
  const RepoTile({
    super.key,
    required this.repo,
    required this.onTap,
  });

  final GithubRepository repo;
  final ValueChanged<GithubRepository> onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(repo),
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              String.fromCharCodes(Runes('\u2022')),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[400]!,
                            offset: const Offset(1, 2),
                            blurRadius: 3,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          repo.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[400]!,
                          offset: const Offset(1, 2),
                          blurRadius: 3,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 18,
                          shadows: [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(.2, .2),
                              spreadRadius: 2.2,
                            )
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${repo.stargazerCount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
