extension IterableExtension<T> on Iterable<T> {
  List<T> toSortedList([int compare(a, b)?]) {
    final result = this.toList();
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

  T? findOrNull(bool Function(T) test) => cast<T?>().firstWhere((it) => test(it!), orElse: () => null);

  T? firstOrNull([bool Function(T)? test]) => findOrNull(test ?? (_) => true);
}

extension IterableExtensionNullable<T extends Object> on Iterable<T?> {
  Iterable<T> whereNotNull() => this.where((element) => element != null).cast<T>();
}
