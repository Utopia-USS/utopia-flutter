import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:utopia_hooks/utopia_hooks.dart';

import '../core/core.dart';
import 'use_query_client.dart';

/// A hook for fetching, caching, and subscribing to async data.
///
/// This hook manages the complete lifecycle of async data fetching, including
/// request deduplication, caching, background refetching, and stale-while-
/// revalidate patterns.
///
/// The [queryKey] uniquely identifies this query in the cache. Queries with the
/// same key share cached data across the widget tree.
///
/// The [queryFn] fetches the data when the query needs to execute. It receives
/// a [QueryFunctionContext] with the query key and other metadata.
///
/// Returns a [QueryResult] containing the current state of the query, including
/// data, error, and status flags. The widget rebuilds automatically when the
/// query state changes.
///
/// ## Options
///
/// - [enabled]: Whether the query should execute. Defaults to `true`. Set to
///   `false` to disable automatic fetching.
///
/// - [networkMode]: The network connectivity mode for this query. Has no
///   effect unless [connectivityChanges] is provided to [QueryClient]. Can be
///   [NetworkMode.online] (default, pauses when offline), [NetworkMode.always]
///   (ignores network state), or [NetworkMode.offlineFirst] (first fetch runs
///   immediately, retries pause when offline).
///
/// - [staleDuration]: How long data remains fresh before becoming stale.
///   Stale data may be refetched on the next access. Defaults to zero (data is
///   immediately stale).
///
/// - [gcDuration]: How long unused data remains in cache before garbage
///   collection. Defaults to 5 minutes.
///
/// - [placeholder]: Data to display while the query is pending and has no
///   cached data. Unlike [seed], placeholder data is not persisted to the
///   cache.
///
/// - [refetchOnMount]: Controls refetch behavior when this hook mounts. Can be
///   [RefetchOnMount.stale] (default), [RefetchOnMount.always], or
///   [RefetchOnMount.never].
///
/// - [refetchOnResume]: Controls refetch behavior when the app resumes from
///   background. Can be [RefetchOnResume.stale] (default),
///   [RefetchOnResume.always], or [RefetchOnResume.never].
///
/// - [refetchOnReconnect]: Controls refetch behavior when network connectivity
///   is restored. Can be [RefetchOnReconnect.stale] (default),
///   [RefetchOnReconnect.always], or [RefetchOnReconnect.never]. Requires
///   [connectivityChanges] to be provided to [QueryClient].
///
/// - [refetchInterval]: Automatically refetch at the specified interval while
///   this hook is mounted.
///
/// - [retry]: A callback that controls retry behavior on failure. Returns a
///   [Duration] to retry after waiting, or `null` to stop retrying. Defaults
///   to 3 retries with exponential backoff (1s, 2s, 4s).
///
/// - [retryOnMount]: Whether to retry failed queries when this hook mounts.
///   Defaults to `true`.
///
/// - [seed]: Initial data to populate the cache before the first fetch. Unlike
///   [placeholder], seed data is persisted to the cache.
///
/// - [seedUpdatedAt]: The timestamp when [seed] data was last updated. Used to
///   determine staleness of seed data.
///
/// - [meta]: A map of arbitrary metadata attached to this query, accessible
///   in the query function context. When multiple hooks share the same query
///   key, their [meta] maps are deep merged.
///
/// - [client]: The [QueryClient] to use. If provided, takes precedence over
///   the nearest [QueryClientProvider] ancestor.
///
/// See also:
///
/// - [useInfiniteQuery] for paginated data
/// - [useMutation] for create, update, and delete operations
/// - [QueryClient.prefetchQuery] for prefetching data before it's needed
QueryResult<TData, TError> useQuery<TData, TError>(
  List<Object?> queryKey,
  QueryFn<TData> queryFn, {
  bool? enabled,
  NetworkMode? networkMode,
  StaleDuration? staleDuration,
  GcDuration? gcDuration,
  TData? placeholder,
  RefetchOnMount? refetchOnMount,
  RefetchOnResume? refetchOnResume,
  RefetchOnReconnect? refetchOnReconnect,
  Duration? refetchInterval,
  RetryResolver<TError>? retry,
  bool? retryOnMount,
  TData? seed,
  DateTime? seedUpdatedAt,
  Map<String, dynamic>? meta,
  QueryClient? client,
}) {
  final effectiveClient = useQueryClient(client);

  // Tracks whether we are currently inside this hook's build. Observer
  // mutations performed during build (e.g. switching queries when the
  // queryKey changes) synchronously notify subscribers; we must not turn
  // those into setState calls, since the build already returns the current
  // observer result. `listen: false` keeps writes from scheduling a rebuild.
  final isBuilding = useState(true, listen: false);
  isBuilding.value = true;

  // Create observer once per component instance
  final observer = useMemoized(
    () => QueryObserver<TData, TError>(
      effectiveClient,
      QueryOptions(
        queryKey,
        queryFn,
        enabled: enabled,
        staleDuration: staleDuration,
        gcDuration: gcDuration,
        meta: meta,
        networkMode: networkMode,
        placeholder: placeholder,
        refetchInterval: refetchInterval,
        refetchOnMount: refetchOnMount,
        refetchOnResume: refetchOnResume,
        refetchOnReconnect: refetchOnReconnect,
        retry: retry,
        retryOnMount: retryOnMount,
        seed: seed,
        seedUpdatedAt: seedUpdatedAt,
      ),
    ),
    [effectiveClient],
  );

  // Mount observer and cleanup on unmount — must be immediate so observer is
  // mounted before useState(observer.result) is called below.
  useImmediateEffect(() {
    observer.onMount();
    return observer.onUnmount;
  }, [observer]);

  // Handle app lifecycle resume events
  useAppLifecycleStateListener(onResumed: observer.onResume);

  // Update options during render (before subscribing)
  observer.options = QueryOptions(
    queryKey,
    queryFn,
    enabled: enabled,
    staleDuration: staleDuration,
    gcDuration: gcDuration,
    meta: meta,
    networkMode: networkMode,
    placeholder: placeholder,
    refetchInterval: refetchInterval,
    refetchOnMount: refetchOnMount,
    refetchOnResume: refetchOnResume,
    refetchOnReconnect: refetchOnReconnect,
    retry: retry,
    retryOnMount: retryOnMount,
    seed: seed,
    seedUpdatedAt: seedUpdatedAt,
  );

  // A rebuild trigger. The hook returns `observer.result` directly (always
  // current), so this state exists only to schedule rebuilds when the result
  // changes outside of the build phase.
  final result = useState(observer.result);

  useEffect(() {
    final unsubscribe = observer.subscribe((newResult) {
      // Notifications fired synchronously while this hook is building (e.g.
      // from the `observer.options =` update above when the queryKey changes)
      // are already reflected by the `observer.result` returned below.
      // Scheduling a rebuild here would reenter the build and corrupt hook
      // state, so skip them.
      if (isBuilding.value) return;

      // During another element's build phase, calling markNeedsBuild on this
      // element is forbidden by Flutter. Defer to a post-frame callback so the
      // update still lands in the next frame.
      if (SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          result.setIfMounted(newResult);
        });
      } else {
        result.value = newResult;
      }
    });
    return unsubscribe;
  }, [observer]);

  isBuilding.value = false;
  return observer.result;
}
