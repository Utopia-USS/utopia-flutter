class HasInitialized {
  const HasInitialized({required this.isInitialized});

  final bool isInitialized;

  static List<bool> keys(Iterable<HasInitialized> list) => list.map((e) => e.isInitialized).toList();

  static bool all(Iterable<HasInitialized> list) => list.every((e) => e.isInitialized);

  static bool any(Iterable<HasInitialized> list) => list.any((e) => e.isInitialized);
}
