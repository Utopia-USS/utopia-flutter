extension SetExtensions<T> on Set<T> {
  Set<T> toggled(T element) {
    if (contains(element)) {
      return difference({element});
    } else {
      return union({element});
    }
  }
}
