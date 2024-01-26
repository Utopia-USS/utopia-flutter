abstract interface class ProviderContext {
  dynamic getUnsafe(Type type);
}

/// An exception thrown by [ProviderContext.getUnsafe] when the requested value can't be provided.
class ProvidedValueNotFoundException implements Exception {
  final Type type;
  final ProviderContext context;

  const ProvidedValueNotFoundException({required this.type, required this.context});

  @override
  String toString() => "Provided value of type $type not found in $context";
}

extension ProviderContextExtensions on ProviderContext {
  T get<T>() => getUnsafe(T) as T;

  T? getOrNull<T>() {
    try {
      return get<T>();
    } on ProvidedValueNotFoundException {
      return null;
    }
  }
}
