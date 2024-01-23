import 'package:utopia_collections/src/extension/iterable_extension.dart';

extension ListExtensions<T> on List<T> {
  T? tryGet(int index) => index < length ? this[index] : null;

  List<T> separatedWith(T value) =>
      asMap().entries.expand((entry) => [if (entry.key != 0) value, entry.value]).toList();

  List<T> minus(List<T> other) => where((it) => !other.contains(it)).toList();

  T? lastOrNull([bool Function(T)? test]) => reversed.findOrNull(test ?? (_) => true);
}
