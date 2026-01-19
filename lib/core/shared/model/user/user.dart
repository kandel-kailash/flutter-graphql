import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:github_graphql_app/src/repos/model/state/search_view_result.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String login,
    required String avatarUrl,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  factory User.fromSearchViewResult(SearchViewResult result) => User(
    id: result.id,
    name: result.name,
    login: result.loginName,
    avatarUrl: result.avatarUrl,
  );
}
