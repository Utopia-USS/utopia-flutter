extension AnyExtensions<T> on T {
  T2 let<T2>(T2 Function(T it) block) => block(this);

  T? takeIf(bool Function(T it) block) => block(this) ? this : null;

  T2 cast<T2 extends T>() => this as T2;

  T2? tryCast<T2 extends T>() => this is T2 ? this as T2 : null;
}