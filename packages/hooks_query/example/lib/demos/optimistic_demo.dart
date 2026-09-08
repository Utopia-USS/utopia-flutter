import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_query/utopia_hooks_query.dart';

import '../api.dart';

/// Optimistic updates with rollback. Toggling a todo flips its checkbox
/// instantly by writing to the cache in `onMutate`; if the mutation fails the
/// snapshot taken before the change is restored in `onError`. Flip "simulate
/// failure" to watch the rollback happen.
class OptimisticDemo extends HookWidget {
  const OptimisticDemo({super.key});

  static const _key = ['todos'];

  @override
  Widget build(BuildContext context) {
    final client = useQueryClient();
    final failMode = useState(false);
    final snapshot = useState<List<Todo>?>(null, listen: false);

    final todos = useQuery<List<Todo>>(_key, (_) => api.fetchTodos());

    final toggle = useMutation<Todo, Todo>(
      (todo, _) async {
        if (failMode.value) throw Exception('Simulated network failure');
        return api.updateTodo(todo);
      },
      onMutate: (info) {
        // Snapshot the current list, then optimistically apply the toggle.
        snapshot.value = client.getQueryData<List<Todo>>(_key);
        client.setQueryData<List<Todo>>(
          _key,
          (prev) => prev
              ?.map((it) => it.id == info.variables.id ? info.variables : it)
              .toList(),
        );
      },
      onError: (info) {
        // Roll back to the pre-mutation snapshot.
        final previous = snapshot.value;
        if (previous != null) client.setQueryData<List<Todo>>(_key, (_) => previous);
      },
      onSettled: (info) => client.invalidateQueries(queryKey: _key),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimistic updates'),
        actions: [
          Row(
            children: [
              const Text('Fail'),
              Switch(value: failMode.value, onChanged: (v) => failMode.value = v),
            ],
          ),
        ],
      ),
      body: switch (todos) {
        QueryResult(:final data?) => ListView(
            children: [
              for (final todo in data)
                CheckboxListTile(
                  value: todo.completed,
                  title: Text(todo.title),
                  onChanged: (_) => toggle.mutate(todo.copyWith(completed: !todo.completed)),
                ),
            ],
          ),
        QueryResult(isPending: true) => const Center(child: CircularProgressIndicator()),
        QueryResult(:final error) => Center(child: Text('Error: $error')),
      },
    );
  }
}
