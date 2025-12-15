import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:utopia_localization_builder/src/definitions/condition.dart';
import 'package:utopia_localization_builder/src/definitions/localizations.dart';
import 'package:utopia_localization_builder/src/definitions/section.dart';
import 'package:utopia_localization_builder/src/definitions/translation.dart';
import 'package:utopia_localization_builder/src/generators/builders/base.dart';
import 'package:utopia_localization_builder/src/generators/builders/property.dart';

import 'builders/argument.dart';
import 'builders/data_class.dart';

class DartLocalizationBuilder {
  DartLocalizationBuilder({this.jsonParser = true, this.fallbackLocale});

  StringBuffer _buffer = StringBuffer();
  final bool jsonParser;
  final String? fallbackLocale;

  String build(Localizations localizations, {required String fieldName}) {
    _buffer = StringBuffer();
    _createPreamble();
    _createLocalization([localizations.name], localizations, fieldName);
    _addSectionDefinition([localizations.name], localizations);
    return DartFormatter(languageVersion: DartFormatter.latestLanguageVersion).format(_buffer.toString());
  }

  void _createPreamble() {
    _buffer.writeln(
        "// ignore_for_file: unnecessary_raw_strings,leading_newlines_in_multiline_strings,no_leading_underscores_for_local_identifiers,prefer_final_locals,join_return_with_assignment");
  }

  void _createLocalization(List<String> path, Localizations localizations, String fieldName) {
    _buffer.writeln('const $fieldName = ${_createLanguageMap(path, localizations)};');
  }

  String _createLanguageMap(List<String> path, Localizations localizations) {
    final result = StringBuffer();

    result.write('UtopiaLocalizationData<${localizations.name}>({');

    for (final languageCode in localizations.supportedLanguageCodes) {
      final instance = _createSectionInstance(path, languageCode, localizations);

      result.write("'$languageCode': $instance,");
    }

    result.write('})');

    return result.toString();
  }

  String _createSectionInstance(
    List<String> path,
    String languageCode,
    Section section,
  ) {
    final effectivePath = [
      ...path,
      section.normalizedKey,
    ];

    final result = StringBuffer();
    result.writeln('${_buildClassNameFromPath(effectivePath)}(');

    for (final label in section.labels) {
      for (final caze in label.cases) {
        if (caze.condition is ValueCondition) {
          final condition = caze.condition as ValueCondition;
          final fieldName = createCaseFieldName(label.normalizedKey, value: condition.value);
          result.write(fieldName);
        } else {
          final fieldName = label.normalizedKey;
          result.write(fieldName);
        }
        Translation? getTranslation(String languageCode) {
          return caze.translations.firstWhereOrNull(
            (x) => x.value.isNotEmpty && x.languageCode == languageCode,
          );
        }

        var translation = getTranslation(languageCode);
        if (fallbackLocale != null) {
          translation ??= getTranslation(fallbackLocale!);
        }
        translation ??= Translation(languageCode, '?');
        result.write(':');
        result.write('r"""${translation.value}""",');
      }
    }

    for (final child in section.children) {
      result.write(child.normalizedKey);
      result.write(':');
      result.write(_createSectionInstance(
        effectivePath,
        languageCode,
        child,
      ));
      result.write(',');
    }

    result.writeln(')');

    return result.toString();
  }

  void _addSectionDefinition(List<String> path, Section section) {
    final effectivePath = [
      ...path,
      section.normalizedKey,
    ];

    final result = DataClassBuilder(
      _buildClassNameFromPath(effectivePath),
      isConst: true,
    );

    for (final label in section.labels) {
      if (label.templatedValues.isEmpty && label.cases.length == 1 && label.cases.first.condition is DefaultCondition) {
        result.addProperty('String', label.normalizedKey);
      } else {
        final methodArguments = <ArgumentBuilder>[];

        /// Adding an argument for each category
        final categoryCases = label.cases.where((x) => x.condition is ValueCondition);
        for (final categoryCase in categoryCases) {
          final condition = categoryCase.condition as ValueCondition;
          final fieldName = '_${createCaseFieldName(label.normalizedKey, value: condition.value)}';
          result.addProperty('String', fieldName);
        }

        if (label.cases.length > 1) {
          methodArguments.add(
            const ArgumentBuilder(
              name: "_value",
              type: "Object?", // TODO typed value?
              named: false,
            ),
          );
        }

        /// Default value
        final hasDefaultCase = label.cases.any((it) => it.condition is DefaultCondition);

        if (hasDefaultCase) {
          result.addProperty('String', '_${label.normalizedKey}');
        }

        /// Adding an argument for each templated value
        for (final templatedValue in label.templatedValues) {
          methodArguments.add(
            ArgumentBuilder(
              name: createFieldName(templatedValue.key),
              type: templatedValue.type,
            ),
          );
        }
        if (label.templatedValues.isNotEmpty) {
          methodArguments.add(
            const ArgumentBuilder(
              name: 'locale',
              type: 'String?',
              isRequired: false,
            ),
          );
        }

        /// Creating method body
        final body = StringBuffer('{\n');

        if (label.cases.any((it) => it.condition is ValueCondition)) {
          body.writeln("var label = switch(_value) {");
          for (final condition in label.cases.map((it) => it.condition).whereType<ValueCondition>()) {
            body.writeln('${condition.value} => _${createCaseFieldName(label.normalizedKey, value: condition.value)},');
          }
          final defaultValue =
              hasDefaultCase ? '_${label.normalizedKey}' : r'throw Exception("No case available for $_value")';
          body.writeln('_ => $defaultValue,');
          body.writeln('};');
        } else {
          body.writeln('var label = _${label.normalizedKey};');
        }

        if (label.templatedValues.isNotEmpty) {
          body.write('label = label.insertTemplateValues({');
          for (final templatedValue in label.templatedValues) {
            body.write("'${templatedValue.key}' : ${createFieldName(templatedValue.key)},");
          }
          body.write('}, locale : locale,);');
        }

        body.writeln('return label;');

        body.writeln('}');

        result.addMethod(
          returnType: 'String',
          name: label.normalizedKey,
          body: body.toString(),
          arguments: methodArguments,
        );
      }
    }

    for (final child in section.children) {
      final childPath = [
        ...effectivePath,
        child.normalizedKey,
      ];
      result.addProperty(
        _buildClassNameFromPath(childPath),
        createFieldName(child.key),
        jsonConverter: fromJsonPropertyBuilderJsonConverter,
        toJson: toJsonPropertyBuilderToJson,
      );
    }

    _buffer.writeln(
      result.build(
        jsonParser: jsonParser,
      ),
    );

    for (final child in section.children) {
      _addSectionDefinition(effectivePath, child);
    }
  }
}

String _buildClassNameFromPath(List<String> path) {
  return path.map(createClassdName).join();
}
