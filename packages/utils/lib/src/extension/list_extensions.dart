extension ListExtensions<T> on List<T> {
  T? tryGet(int index) => index < length ? this[index] : null;

  List<T> separatedWith(T value) =>
      asMap().entries.expand((entry) => [if (entry.key != 0) value, entry.value]).toList();

  List<T> minus(List<T> other) => where((it) => !other.contains(it)).toList();

  T? firstOrNull() => this.isNotEmpty ? this[0] : null;

  List<T2> mapWithNext<T2>(T2 f(T curr, T? next)) =>
      [for (int i = 0; i < this.length; i++) f(this[i], i < length - 1 ? this[i + 1] : null)];
}
