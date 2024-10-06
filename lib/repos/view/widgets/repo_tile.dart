import 'package:github_graphql_app/repos/model/github_repository/github_repository.dart';
import 'package:flutter/material.dart';

class RepoTile extends StatelessWidget {
  final GithubRepository repo;

  const RepoTile({
    super.key,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 24,
      ),
      child: Row(
        children: [
          Text(
            String.fromCharCodes(
              Runes('\u0489'),
            ),
          ),
          const SizedBox(width: 10),
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
              child: InkWell(
                onTap: () {},
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    repo.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
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
                Text(
                  '${repo.stargazerCount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 18,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
