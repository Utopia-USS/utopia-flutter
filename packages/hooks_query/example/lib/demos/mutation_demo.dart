import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_query/utopia_hooks_query.dart';

import '../api.dart';

/// useMutation + cache invalidation. Creating a post fires the mutation, and
/// its onSuccess invalidates the posts list so it refetches. (JSONPlaceholder
/// fakes the write, so the new row won't actually appear — the point is the
/// mutation lifecycle and the invalidation wiring.)
class MutationDemo extends HookWidget {
  const MutationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final client = useQueryClient();
    final title = useFieldState(initialValue: '');

    final list = useQuery(['posts', 'page', 1], (_) => api.fetchPosts(page: 1));

    final create = useMutation<Post, String>(
      (title, _) => api.createPost(title: title, body: 'Created from the example app'),
      onSuccess: (info) {
        title.value = '';
        client.invalidateQueries(queryKey: ['posts']);
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Mutation + invalidation')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextEditingControllerWrapper(
                  text: title,
                  builder: (controller) => TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'New post title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: create.isPending || title.value.trim().isEmpty
                      ? null
                      : () => create.mutate(title.value.trim()),
                  child: create.isPending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create post'),
                ),
                if (create case MutationSuccess(:final data))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Created post #${data.id}'),
                  ),
                if (create case MutationError(:final error))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Failed: $error', style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: switch (list) {
              QueryResult(:final data?) => ListView(
                  children: [
                    for (final post in data)
                      ListTile(leading: Text('${post.id}'), title: Text(post.title)),
                  ],
                ),
              QueryResult(isPending: true) => const Center(child: CircularProgressIndicator()),
              QueryResult(:final error) => Center(child: Text('Error: $error')),
            },
          ),
        ],
      ),
    );
  }
}
