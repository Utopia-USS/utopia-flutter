import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_query/utopia_hooks_query.dart';

import '../api.dart';

/// Dependent queries via `enabled`. The posts query only runs once a user is
/// selected; until then it stays idle. Picking a user flips `enabled` true and
/// the second query fires with that user's id.
class DependentQueryDemo extends HookWidget {
  const DependentQueryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedUserId = useState<int?>(null);

    final users = useQuery<List<User>>(['users'], (_) => api.fetchUsers());

    final posts = useQuery<List<Post>>(
      ['posts', 'byUser', selectedUserId.value],
      (_) => api.fetchPostsByUser(selectedUserId.value!),
      enabled: selectedUserId.value != null,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Dependent queries')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: switch (users) {
              QueryResult(:final data?) => DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text('Pick a user'),
                  value: selectedUserId.value,
                  items: [
                    for (final user in data)
                      DropdownMenuItem(value: user.id, child: Text(user.name)),
                  ],
                  onChanged: (id) => selectedUserId.value = id,
                ),
              QueryResult(isPending: true) => const LinearProgressIndicator(),
              QueryResult(:final error) => Text('Error: $error'),
            },
          ),
          const Divider(height: 1),
          Expanded(child: _Posts(posts: posts, hasUser: selectedUserId.value != null)),
        ],
      ),
    );
  }
}

class _Posts extends StatelessWidget {
  const _Posts({required this.posts, required this.hasUser});

  final QueryResult<List<Post>> posts;
  final bool hasUser;

  @override
  Widget build(BuildContext context) {
    if (!hasUser) {
      return const Center(child: Text('Select a user to load their posts'));
    }
    return switch (posts) {
      QueryResult(:final data?) => ListView(
          children: [
            for (final post in data)
              ListTile(title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      QueryResult(isPending: true) => const Center(child: CircularProgressIndicator()),
      QueryResult(:final error) => Center(child: Text('Error: $error')),
    };
  }
}
