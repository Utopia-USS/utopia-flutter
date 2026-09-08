import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks_query/src/core/core.dart';

QueryResult<int> _success(int data) => QuerySuccess(
      data: data,
      fetchStatus: FetchStatus.idle,
      dataUpdatedAt: null,
      dataUpdateCount: 1,
      errorUpdatedAt: null,
      errorUpdateCount: 0,
      failureCount: 0,
      failureReason: null,
      isEnabled: true,
      isStale: false,
      isFetchedAfterMount: true,
      isPlaceholderData: false,
      refetch: ({cancelRefetch = true, throwOnError = false}) async => _success(data),
    );

void main() {
  group('sealed variants', () {
    test('SHOULD narrow data to non-null in the QuerySuccess branch', () {
      final result = _success(42);

      final value = switch (result) {
        QueryPending() => -1,
        // `data` is statically non-null here — no `!` needed.
        QuerySuccess(:final data) => data,
        QueryError() => -1,
      };

      expect(value, 42);
    });

    test('SHOULD route the compatibility factory to the matching subtype', () {
      QueryResult<int> build(QueryStatus status) => QueryResult(
            status: status,
            fetchStatus: FetchStatus.idle,
            data: status == QueryStatus.success ? 7 : null,
            dataUpdatedAt: null,
            dataUpdateCount: 0,
            error: status == QueryStatus.error ? Exception('x') : null,
            errorUpdatedAt: null,
            errorUpdateCount: 0,
            failureCount: 0,
            failureReason: null,
            isEnabled: true,
            isStale: false,
            isFetchedAfterMount: false,
            isPlaceholderData: false,
            refetch: ({cancelRefetch = true, throwOnError = false}) async => build(status),
          );

      expect(build(QueryStatus.pending), isA<QueryPending<int>>());
      expect(build(QueryStatus.success), isA<QuerySuccess<int>>());
      expect(build(QueryStatus.error), isA<QueryError<int>>());
    });

    test('SHOULD expose status and flags consistently with the subtype', () {
      final result = _success(1);

      expect(result.status, QueryStatus.success);
      expect(result.isSuccess, isTrue);
      expect(result.isPending, isFalse);
      expect(result.isError, isFalse);
      expect(result.error, isNull);
    });
  });
}
