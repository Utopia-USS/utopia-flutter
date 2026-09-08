import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_query/utopia_hooks_query.dart';

import '../api.dart';

/// The simplest useQuery: fetch one post, render its three states, refetch on
/// demand. Mirrors TanStack's "Simple" example.
class BasicQueryDemo extends HookWidget {
  const BasicQueryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final result = useQuery(['post', 1], (_) => api.fetchPost(1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic query'),
        actions: [
          if (result.isFetching) const _AppBarSpinner(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => result.refetch(),
          ),
        ],
      ),
      body: switch (result) {
        QueryResult(:final data?) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(data.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(data.body),
            ],
          ),
        QueryResult(isPending: true) => const Center(child: CircularProgressIndicator()),
        QueryResult(:final error) => Center(child: Text('Error: $error')),
      },
    );
  }
}

class _AppBarSpinner extends StatelessWidget {
  const _AppBarSpinner();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      );
}
