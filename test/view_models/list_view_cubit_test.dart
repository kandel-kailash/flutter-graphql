import 'package:flutter/widgets.dart';
import 'package:github_graphql_app/src/repos/model/state/list_view_state.dart';
import 'package:github_graphql_app/src/repos/services/graphql_config.dart';
import 'package:github_graphql_app/src/repos/view_modal/list_view_cubit.dart';
import 'package:oauth2/oauth2.dart';
import 'package:test/test.dart';

void main() {
  group('Testing ListViewCubit', () {
    late ListViewCubit cubit;

    setUp(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await GraphQLConfig().initializeClient(Credentials(''));
      cubit = ListViewCubit();
    });

    test('Initializing the cubit', () {
      expect(cubit.state == const ListViewState.initial(), true);
    });
  });
}
