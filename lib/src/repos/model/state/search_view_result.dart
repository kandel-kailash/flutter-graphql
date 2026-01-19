final class SearchViewResult {
  SearchViewResult({
    required this.id,
    required this.name,
    required this.loginName,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String loginName;
  final String avatarUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchViewResult &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          loginName == other.loginName &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode => Object.hashAll([id, name, loginName, avatarUrl]);

  factory SearchViewResult.fromJson(Map<String, dynamic> json) =>
      SearchViewResult(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        loginName: json['login'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
      );
}
