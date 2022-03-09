Comparator<T> compareBy<T>(Iterable<Comparable<dynamic> Function(T)> selectors) {
  return (a, b) {
    for (final selector in selectors) {
      final result = selector(a).compareTo(selector(b));
      if (result != 0) return result;
    }
    return 0;
  };
}
