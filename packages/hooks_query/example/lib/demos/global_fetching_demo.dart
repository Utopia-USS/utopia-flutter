import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_query/utopia_hooks_query.dart';

import '../api.dart';

/// Global fetching indicator with useIsFetching. Three independent queries feed
/// one app-bar spinner that shows whenever *any* of them is in flight — no
/// prop-drilling of loading flags. "Refetch all" invalidates everything at once.
class GlobalFetchingDemo extends HookWidget {
  const GlobalFetchingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final client = useQueryClient();
    final fetching = useIsFetching();

    final users = useQuery<List<User>>(['users'], (_) => api.fetchUsers());
    final todos = useQuery<List<Todo>>(['todos'], (_) => api.fetchTodos());
    final post = useQuery(['post', 1], (_) => api.fetchPost(1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global fetching'),
        actions: [
          if (fetching > 0)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => client.invalidateQueries(),
          ),
        ],
      ),
      body: ListView(
        children: [
          _Tile(label: 'Queries fetching now', value: '$fetching'),
          const Divider(),
          _Tile(
            label: 'Users',
            value: switch (users) {
              QueryResult(:final data?) => '${data.length} loaded',
              QueryResult(isPending: true) => 'loading…',
              _ => 'error',
            },
          ),
          _Tile(
            label: 'Todos',
            value: switch (todos) {
              QueryResult(:final data?) => '${data.length} loaded',
              QueryResult(isPending: true) => 'loading…',
              _ => 'error',
            },
          ),
          _Tile(
            label: 'Post #1',
            value: switch (post) {
              QueryResult(:final data?) => data.title.split(' ').take(3).join(' '),
              QueryResult(isPending: true) => 'loading…',
              _ => 'error',
            },
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      );
}
