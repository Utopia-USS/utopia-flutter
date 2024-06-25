import 'package:collection/collection.dart';

import 'argument.dart';

class MethodBuilder {
  const MethodBuilder({
    required this.name,
    required this.body,
    required this.returnType,
    required this.arguments,
  });

  final String name;
  final String returnType;
  final String body;
  final List<ArgumentBuilder> arguments;

  String build() {
    final result = StringBuffer();
    result.write('$returnType $name(');
    final groupedArguments = arguments.groupListsBy((x) => x.named);
    for(final argument in groupedArguments[false] ?? <ArgumentBuilder>[]) result.write(argument.build() + ',');
    if (groupedArguments[true] != null) {
      result.write('{');
      for (final argument in groupedArguments[true]!) {
        result.write(argument.build());
        result.write(',');
      }
      result.write('}');
    }
    result.write(') $body');
    return result.toString();
  }
}
