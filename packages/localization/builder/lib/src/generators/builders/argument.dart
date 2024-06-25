class ArgumentBuilder {
  const ArgumentBuilder({
    required this.name,
    required this.type,
    this.defaultValue,
    this.isRequired = true,
    this.named = true,
  });
  final String name;
  final String type;
  final String? defaultValue;
  final bool isRequired;
  final bool named;

  String build() {
    final result = StringBuffer();
    if (named && defaultValue == null && isRequired) {
      result.write('required ');
    }
    result.write('$type $name');
    if (named && defaultValue != null) {
      result.write('= $defaultValue');
    }
    return result.toString();
  }
}
