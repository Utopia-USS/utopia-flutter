import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/search/clean/repository/user_repository.dart';

class SearchPageState {
  final FieldState search;
  final List<String>? results;

  const SearchPageState({required this.search, required this.results});

  bool get isLoading => results == null;

  bool get isEmpty => !isLoading && results!.isEmpty;
}

SearchPageState useSearchPageState() {
  final userRepository = useProvided<UserRepository>();

  final search = useFieldState();

  final state = useAutoComputedState(
    debounceDuration: const Duration(milliseconds: 500),
    keys: [search.value],
    () async => userRepository.getUsers(name: search.value.isEmpty ? null : search.value),
  );

  final results = useMemoized(() => state.valueOrNull?.map((it) => it.name).toList(), [state.valueOrNull]);

  return SearchPageState(search: search, results: results);
}
