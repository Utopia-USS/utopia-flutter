import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_query/utopia_hooks_query.dart';

import '../api.dart';

/// Auto-refetching with `refetchInterval`. The query re-runs on a timer while
/// mounted. JSONPlaceholder returns the same post each time, so the proof of
/// polling is the fetch counter and the "last updated" timestamp ticking up.
class PollingDemo extends HookWidget {
  const PollingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final seconds = useState(3);

    final result = useQuery(
      ['post', 1, 'polled'],
      (_) => api.fetchPost(1),
      refetchInterval: Duration(seconds: seconds.value),
      staleDuration: StaleDuration.zero,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polling'),
        actions: [if (result.isFetching) const _Spinner()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Refetch every ${seconds.value}s'),
            Slider(
              value: seconds.value.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '${seconds.value}s',
              onChanged: (v) => seconds.value = v.round(),
            ),
            const SizedBox(height: 16),
            Text('Fetches: ${result.dataUpdateCount}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Last updated: ${result.dataUpdatedAt?.toLocal().toString().split('.').first ?? '—'}'),
            const SizedBox(height: 24),
            if (result.data case final data?) Text(data.title),
          ],
        ),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

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
