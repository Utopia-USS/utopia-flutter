import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/search/clean/repository/user_repository.dart';
import 'package:utopia_hooks_example/search/clean/search/state/search_page_state.dart';

final _userNames = MockUserRepository.users.map((it) => it.name).toList();

void main() {
  group("SearchPageState", () {
    late SimpleHookContext<SearchPageState> context;

    setUp(() {
      context = SimpleHookContext(useSearchPageState, provided: {UserRepository: const MockUserRepository()});
    });

    test("Initial state", () async {
      expect(context().search.value, "");
      expect(context().results, null);
      await context.waitUntil((it) => it.results != null);
      expect(context().results, _userNames);
    });

    test("Search", () async {
      await context.waitUntil((it) => it.results != null);
      context().search.value = "A";
      await Future<void>.delayed(const Duration(seconds: 1)); // Wait for debounce
      await context.waitUntil((it) => it.results != null);
      expect(context().results!.length, _userNames.where((it) => it == 'A').length);
    });
  });
}
