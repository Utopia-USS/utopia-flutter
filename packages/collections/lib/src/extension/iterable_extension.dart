import 'dart:collection';

extension IterableExtension<T> on Iterable<T> {
  List<T> toSortedList([int Function(T a, T b)? compare]) {
    final result = toList();
    result.sort(compare);
    return result;
  }

  Map<K, List<T>> groupBy<K>(K Function(T) selector) {
    final result = <K, List<T>>{};
    forEach((element) => (result[selector(element)] ??= []).add(element));
    return result;
  }

  double avgBy(double Function(T) selector) {
    var sum = 0.0;
    var count = 0;
    forEach((element) {
      sum += selector(element);
      count++;
    });
    return sum / count;
  }

  T? findOrNull(bool Function(T) test) => cast<T?>().firstWhere((it) => test(it as T), orElse: () => null);

  T? firstOrNull([bool Function(T)? test]) => findOrNull(test ?? (_) => true);

  /// Returns a new lazy [Iterable] containing only elements from the collection
  /// having distinct keys returned by the given [selector] function.
  ///
  /// The elements in the resulting list are in the same order as they were in
  /// the source collection.
  Iterable<T> distinctBy<R>(R Function(T element) selector) sync* {
    final existing = HashSet<R>();
    for (final current in this) {
      if (existing.add(selector(current))) {
        yield current;
      }
    }
  }
}

extension IterableExtensionNullable<T extends Object> on Iterable<T?> {
  Iterable<T> whereNotNull() => where((element) => element != null).cast<T>();
}
