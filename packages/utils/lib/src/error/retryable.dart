class Retryable {
  final void Function() _retry;

  const Retryable._(this._retry);

  void retry() => _retry();

  static final _expando = Expando<Retryable>();

  static Retryable make(Object object, void Function() retry) {
    assert(object is! Retryable, "Object is already retryable");
    final retryable = Retryable._(retry);
    _expando[object] = retryable;
    return retryable;
  }

  static Retryable? tryGet(Object object) => object is Retryable ? object : _expando[object];
}