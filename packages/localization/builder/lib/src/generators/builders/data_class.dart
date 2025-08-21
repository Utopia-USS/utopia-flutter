import 'package:utopia_localization_builder/utopia_localization_builder.dart';

class DataClassBuilder {
  final String name;
  final Map<String, PropertyBuilder> _properties = {};
  final Map<String, MethodBuilder> _methods = {};
  final Map<String, Map<String, String>> _constructors = {};
  final bool isConst;

  DataClassBuilder(
    this.name, {
    this.isConst = true,
  });

  void addProperty(
    String type,
    String name, {
    String? defaultValue,
    PropertyBuilderJsonConverter jsonConverter = defaultPropertyBuilderJsonConverter,
    PropertyBuilderToJson toJson = defaultPropertyBuilderToJson,
  }) {
    final isPrivate = name.startsWith('_');
    final property = PropertyBuilder(
      name: isPrivate ? name.substring(1) : name,
      type: type,
      defaultValue: defaultValue,
      jsonConverter: jsonConverter,
      toJson: toJson,
      isPrivate: isPrivate,
    );
    _properties[property.argumentName] = property;
  }

  void addMethod({
    required String returnType,
    required String name,
    List<ArgumentBuilder> arguments = const <ArgumentBuilder>[],
    required String body,
  }) {
    final method = MethodBuilder(
      name: name,
      returnType: returnType,
      arguments: arguments,
      body: body,
    );
    _methods[method.name] = method;
  }

  void addConstructor(String name, Map<String, String> properties) {
    _constructors[name] = properties;
  }

  String build({
    bool jsonParser = true,
    bool copyWith = true,
    bool equalityComparer = true,
  }) {
    final propertyNames = _properties.keys.toList();

    final buffer = StringBuffer('class $name {\n');

    if (isConst) {
      // Default constructor
      buffer.writeln();
      buffer.writeln('  const $name(');
      if (propertyNames.isNotEmpty) {
        buffer.write('{');
        for (final propertyName in propertyNames) {
          final property = _properties[propertyName]!;
          buffer.write(property.buildConstructorParameter());
          buffer.writeln(',');
        }
        buffer.write('}');
      }
      buffer.write(')');

      final initializers = <String>[];
      if (propertyNames.isNotEmpty) {
        for (var i = 0; i < propertyNames.length; i++) {
          final propertyName = propertyNames[i];
          final property = _properties[propertyName]!;
          initializers.addAll(property.buildConstructorInitializers());
        }
      }

      if (initializers.isNotEmpty) {
        buffer.write(': ${initializers.join(',')}');
      }
      buffer.writeln(';');

      // Constructors
      for (final constructor in _constructors.entries) {
        buffer.writeln();
        buffer.write('  const $name.${constructor.key}()');
        if (_properties.isNotEmpty) {
          buffer.writeln(' : ');
          for (var i = 0; i < propertyNames.length; i++) {
            final propertyName = propertyNames[i];
            final property = _properties[propertyName]!;
            final value = constructor.value[propertyName];
            buffer.write('    this.${property.argumentName} = $value');
            buffer.writeln(i == propertyNames.length - 1 ? ';' : ',');
          }
        }
      }

      // Properties
      if (propertyNames.isNotEmpty) {
        buffer.writeln();
        for (final propertyName in propertyNames) {
          final property = _properties[propertyName]!;
          //propertyName = createFieldName(propertyName);
          buffer.writeln(property.buildField());
        }
      }
    } else {
      // Default constructor
      buffer.writeln();
      buffer.writeln('  const $name({');
      for (final propertyName in propertyNames) {
        final property = _properties[propertyName];
        final propertyType = property!.type;
        //propertyName = createFieldName(propertyName);

        buffer.writeln('required $propertyType ${property.argumentName},');
      }
      buffer.writeln('  }) : ');

      if (propertyNames.isNotEmpty) {
        for (var i = 0; i < propertyNames.length; i++) {
          final propertyName = propertyNames[i];
          final property = _properties[propertyName]!;
          //propertyName = createFieldName(propertyName);
          buffer.write('    _${property.argumentName} = ${property.argumentName}');
          buffer.writeln(i == propertyNames.length - 1 ? ';' : ',');
        }
      } else {
        buffer.writeln(';');
      }

      // Default null constructor
      buffer.writeln();
      buffer.writeln('  const $name._() : ');

      if (propertyNames.isNotEmpty) {
        for (var i = 0; i < propertyNames.length; i++) {
          final propertyName = propertyNames[i];
          final property = _properties[propertyName]!;
          buffer.write('    _${property.fieldName} = null');
          buffer.writeln(i == propertyNames.length - 1 ? ';' : ',');
        }
      } else {
        buffer.writeln(';');
      }

      // Constructors
      for (final constructor in _constructors.entries) {
        buffer.writeln();

        buffer.write('  const factory $name.${constructor.key}() = _$name${createClassdName(constructor.key)};');
      }

      // Properties
      if (propertyNames.isNotEmpty) {
        buffer.writeln();
        for (var propertyName in propertyNames) {
          final property = _properties[propertyName]!;
          final propertyType = property.type;
          propertyName = createFieldName(propertyName);
          buffer.writeln('  final $propertyType? _${property.fieldName};');
          final value = '_${property.fieldName}!';
          buffer.writeln('  $propertyType get $propertyName => $value;');
        }
      }
    }

    // Methods
    if (_methods.isNotEmpty) {
      buffer.writeln();
      for (final method in _methods.values) {
        buffer.writeln(method.build());
      }
    }

    // JSON Parsers
    if (jsonParser) {
      buffer.write('  factory $name.fromJson(Map<String, Object?> map) => $name(');

      if (propertyNames.isNotEmpty) {
        for (var i = 0; i < propertyNames.length; i++) {
          final propertyName = propertyNames[i];
          final property = _properties[propertyName]!;
          buffer.write('${property.argumentName} : ');
          final value = "map['$propertyName']!";
          buffer.write(property.jsonConverter(value));
          buffer.write(',');
        }
      }
      buffer.writeln(');');

      buffer.write('Map<String, Object?> toJson() => {');
      if (propertyNames.isNotEmpty) {
        for (var i = 0; i < propertyNames.length; i++) {
          final propertyName = propertyNames[i];
          final property = _properties[propertyName]!;
          buffer.write("'$propertyName' : ");
          final value = property.toJson(property.isPrivate ? '_${property.argumentName}' : property.argumentName);
          buffer.write(value);
          buffer.write(',');
        }
      }
      buffer.writeln('};');
    }

    // CopyWith
    if (copyWith) {
      buffer.writeln();
      buffer.writeln('  $name copyWith(');
      if (_properties.isNotEmpty) {
        buffer.writeln('{');
        for (var propertyName in _properties.keys) {
          final property = _properties[propertyName]!;
          final propertyType = property.type;
          propertyName = createFieldName(propertyName);
          buffer.writeln('    $propertyType? ${property.argumentName},');
        }
        buffer.writeln('}');
      }
      buffer.writeln(') => $name(');
      for (var propertyName in _properties.keys) {
        final property = _properties[propertyName]!;
        propertyName = createFieldName(propertyName);
        buffer.writeln(
            '   ${property.argumentName}: ${property.argumentName} ?? ${property.isPrivate ? '' : 'this.'}${property.fieldName},');
      }
      buffer.writeln('  );');
    }

    if (equalityComparer) {
      // Operator ==
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.write('  bool operator ==(Object other) => ');
      buffer.writeln('identical(this, other) || (other is $name');
      for (final propertyName in _properties.keys) {
        final property = _properties[propertyName]!;
        buffer.writeln('     && ${property.fieldName} == other.${property.fieldName}');
      }
      buffer.writeln('  );');

      // Hashcode
      buffer.writeln('  @override');
      buffer.writeln('  int get hashCode => runtimeType.hashCode');
      if (propertyNames.isEmpty) {
        buffer.writeln(';');
      } else {
        for (var i = 0; i < propertyNames.length; i++) {
          final propertyName = propertyNames[i];
          final property = _properties[propertyName]!;
          buffer.writeln('    ^ ${property.fieldName}.hashCode${i == propertyNames.length - 1 ? ';' : ''}');
        }
      }
    }

    buffer.writeln('}');

    // Final classes
    if (!isConst) {
      for (final constructor in _constructors.entries) {
        buffer.writeln();
        buffer.writeln('class _$name${createClassdName(constructor.key)} extends $name {\n');

        buffer.writeln('  const _$name${createClassdName(constructor.key)}() : super._();');

        // Properties
        if (propertyNames.isNotEmpty) {
          buffer.writeln();
          for (final propertyName in propertyNames) {
            final property = _properties[propertyName]!;
            final propertyType = property.type;
            var value = constructor.value[propertyName];
            value ??= constructor.value.entries
                .firstWhere(
                  (x) => createFieldName(x.key) == propertyName,
                  orElse: () => throw Exception(
                      'No property found with name "$propertyName" in "${constructor.value.keys.join(', ')}"'),
                )
                .value;
            buffer.writeln('  @override');
            buffer.writeln('  $propertyType get ${property.argumentName} => _${property.fieldName}Instance;');
            buffer.writeln('  static final _${property.fieldName}Instance = $value;');
          }
        }

        buffer.writeln('}');
      }
    }

    return buffer.toString();
  }
}
