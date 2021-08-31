extension StringExtensions on String {
  String? nullIfEmpty() => isEmpty ? null : this;
}
