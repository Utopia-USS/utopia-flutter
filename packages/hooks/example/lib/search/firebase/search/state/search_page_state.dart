import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class SearchPageState {
  final FieldState search;
  final List<String>? results;

  const SearchPageState({required this.search, required this.results});

  bool get isLoading => results == null;

  bool get isEmpty => !isLoading && results!.isEmpty;
}

SearchPageState useSearchPageState() {
  final search = useFieldState();
  final debouncedSearch = useDebounced(search.value, duration: const Duration(milliseconds: 500));

  Stream<List<String>> createStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('users');
    if (search.value.isNotEmpty) query = query.where('name', isEqualTo: debouncedSearch);
    return query.snapshots().map((it) => it.docs.map((it) => it['name'] as String).toList());
  }

  final stream = useMemoized(createStream, [debouncedSearch]);
  final snapshot = useStream(stream, preserveState: false);

  return SearchPageState(search: search, results: snapshot.data);
}
