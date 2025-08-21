class PropertyBuilder {
  const PropertyBuilder({
    required this.name,
    required this.type,
    required this.isPrivate,
    this.defaultValue,
    PropertyBuilderJsonConverter jsonConverter = defaultPropertyBuilderJsonConverter,
    PropertyBuilderToJson toJson = defaultPropertyBuilderToJson,
  })  : _jsonConverter = jsonConverter,
        _toJson = toJson;

  final String name;
  final String type;
  final bool isPrivate;
  final String? defaultValue;
  final PropertyBuilderJsonConverter _jsonConverter;
  final PropertyBuilderToJson _toJson;

  String get fieldName => '${isPrivate ? '_' : ''}$argumentName';

  String get argumentName => name;

  String jsonConverter(String value) => _jsonConverter(this, value);

  String toJson(String value) => _toJson(this, value);

  String buildConstructorParameter() {
    final result = StringBuffer();
    result.write('required');
    result.write(' ${isPrivate ? '$type ' : 'this.'}$argumentName');
    return result.toString();
  }

  List<String> buildConstructorInitializers() {
    return [
      if (isPrivate) '$fieldName = $argumentName',
    ];
  }

  String buildField() {
    return 'final $type $fieldName;';
  }
}

typedef PropertyBuilderJsonConverter = String Function(
  PropertyBuilder property,
  String value,
);

typedef PropertyBuilderToJson = String Function(PropertyBuilder property, String value);

String defaultPropertyBuilderJsonConverter(
  PropertyBuilder property,
  String value,
) {
  if (property.type == 'String') {
    return '$value as String';
  } else if (property.type == 'bool') {
    return '$value as bool';
  } else if (property.type == 'int') {
    return '($value as num).toInt()';
  } else if (property.type == 'double') {
    return '($value as num).toDouble()';
  } else if (property.type == 'DateTime') {
    return 'DateTime.parse($value as String)';
  } else {
    return value;
  }
}

String defaultPropertyBuilderToJson(PropertyBuilder property, String value) => value;

String fromJsonPropertyBuilderJsonConverter(
  PropertyBuilder property,
  String value,
) {
  return '${property.type}.fromJson($value as Map<String,Object?>)';
}

String toJsonPropertyBuilderToJson(PropertyBuilder property, String value) => '$value.toJson()';
