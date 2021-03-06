abstract class HasInitialized {
  const HasInitialized._();

  abstract final bool isInitialized;

  static List<bool> keys(List<HasInitialized> list) => list.map((e) => e.isInitialized).toList();

  static bool all(List<HasInitialized> list) => list.every((e) => e.isInitialized);

  static bool any(List<HasInitialized> list) => list.any((e) => e.isInitialized);
}