import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_query/utopia_hooks_query.dart';

import '../api.dart';

/// Page-at-a-time pagination. The previous page stays on screen while the next
/// one loads (TanStack's `keepPreviousData`) by feeding the last data back in
/// as `placeholder`. `isPlaceholderData` dims the list during the transition.
class PaginationDemo extends HookWidget {
  const PaginationDemo({super.key});

  static const _lastPage = 10; // 100 posts / 10 per page

  @override
  Widget build(BuildContext context) {
    final page = useState(1);
    final lastData = useState<List<Post>?>(null, listen: false);

    final result = useQuery(
      ['posts', 'page', page.value],
      (_) => api.fetchPosts(page: page.value),
      placeholder: lastData.value,
    );
    if (result.data case final data?) lastData.value = data;

    return Scaffold(
      appBar: AppBar(title: const Text('Pagination')),
      body: Column(
        children: [
          Expanded(
            child: switch (result) {
              QueryResult(:final data?) => Opacity(
                  opacity: result.isPlaceholderData ? 0.5 : 1,
                  child: ListView(
                    children: [
                      for (final post in data)
                        ListTile(
                          leading: Text('${post.id}'),
                          title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                  ),
                ),
              QueryResult(isPending: true) => const Center(child: CircularProgressIndicator()),
              QueryResult(:final error) => Center(child: Text('Error: $error')),
            },
          ),
          _Pager(
            page: page.value,
            lastPage: _lastPage,
            isFetching: result.isPlaceholderData,
            onPrev: () => page.value = (page.value - 1).clamp(1, _lastPage),
            onNext: () => page.value = (page.value + 1).clamp(1, _lastPage),
          ),
        ],
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager({
    required this.page,
    required this.lastPage,
    required this.isFetching,
    required this.onPrev,
    required this.onNext,
  });

  final int page;
  final int lastPage;
  final bool isFetching;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton.tonal(
                onPressed: page > 1 ? onPrev : null,
                child: const Text('Previous'),
              ),
              Row(
                children: [
                  if (isFetching)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  const SizedBox(width: 8),
                  Text('Page $page / $lastPage'),
                ],
              ),
              FilledButton.tonal(
                onPressed: page < lastPage ? onNext : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      );
}
