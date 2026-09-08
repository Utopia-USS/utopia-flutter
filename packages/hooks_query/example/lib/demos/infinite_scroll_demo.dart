import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_query/utopia_hooks_query.dart';

import '../api.dart';

/// Infinite scroll with useInfiniteQuery. Each page is a `List<Post>`; the next
/// page param is the next page number until a short page signals the end.
/// Fetches the next page automatically as the list nears its bottom.
class InfiniteScrollDemo extends HookWidget {
  const InfiniteScrollDemo({super.key});

  static const _pageSize = 10;

  @override
  Widget build(BuildContext context) {
    final result = useInfiniteQuery<List<Post>, int>(
      ['posts', 'infinite'],
      (context) => api.fetchPosts(page: context.pageParam, limit: _pageSize),
      initialPageParam: 1,
      nextPageParamBuilder: (data) {
        final lastPage = data.pages.last;
        if (lastPage.length < _pageSize) return null; // reached the end
        return data.pageParams.last + 1;
      },
    );

    final posts = [for (final page in result.pages) ...page];

    return Scaffold(
      appBar: AppBar(title: const Text('Infinite scroll')),
      body: switch (result) {
        InfiniteQueryResult(isPending: true) => const Center(child: CircularProgressIndicator()),
        InfiniteQueryResult(isError: true, :final error) => Center(child: Text('Error: $error')),
        _ => NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final atBottom = notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 400;
              if (atBottom && result.hasNextPage && !result.isFetchingNextPage) {
                result.fetchNextPage();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: posts.length + 1,
              itemBuilder: (context, index) {
                if (index == posts.length) return _Footer(result: result);
                final post = posts[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${post.id}')),
                  title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                );
              },
            ),
          ),
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.result});

  final InfiniteQueryResult<List<Post>, int> result;

  @override
  Widget build(BuildContext context) {
    if (result.isFetchingNextPage) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!result.hasNextPage) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('— end —')),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: FilledButton(
          onPressed: () => result.fetchNextPage(),
          child: const Text('Load more'),
        ),
      ),
    );
  }
}
