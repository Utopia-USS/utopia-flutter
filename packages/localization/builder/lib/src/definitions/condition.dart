import 'package:equatable/equatable.dart';

/// A condition can define a [Case] when a [Label] have multiple possible
/// values.
sealed class Condition extends Equatable {
  const Condition();

  factory Condition.parse(String? value) {
    if (value == null) return const DefaultCondition();
    value = value.trim();
    if (value.isEmpty) return const DefaultCondition();
    return ValueCondition(value);
  }
}

/// When a label have a case with no condition.
class DefaultCondition extends Condition {
  const DefaultCondition();

  @override
  List<Object> get props => const <Object>[];
}

/// When a label have a case regarding a category.
class ValueCondition extends Condition {
  const ValueCondition(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}
