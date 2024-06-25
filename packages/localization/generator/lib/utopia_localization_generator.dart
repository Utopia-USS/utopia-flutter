import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:source_gen/source_gen.dart';
import 'package:utopia_localization_annotation/utopia_localization_annotation.dart';
import 'package:utopia_localization_builder/utopia_localization_builder.dart';

class UtopiaLocalizationGenerator extends GeneratorForAnnotation<UtopiaLocalization> {
  const UtopiaLocalizationGenerator();

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! LibraryElement) {
      final name = element.name;
      throw InvalidGenerationSourceError('Generator cannot target `$name`.',
          todo: 'Remove the SheetLocalization annotation from `$name`.', element: element);
    }

    final name = annotation.objectValue.getField('className')!.toStringValue()!;
    final fieldName = annotation.objectValue.getField('fieldName')!.toStringValue()!;
    final docId = annotation.objectValue.getField('docId')!.toStringValue();
    final sheetId = annotation.objectValue.getField('sheetId')!.toStringValue();
    final localizations = await _downloadGoogleSheet(docId!, sheetId!, name);
    final builder = DartLocalizationBuilder(
      jsonParser: annotation.objectValue.getField('jsonSerializers')!.toBoolValue()!,
    );
    final code = StringBuffer();
    code.writeln(builder.build(localizations, fieldName: fieldName));
    return code.toString();
  }

  Future<Localizations> _downloadGoogleSheet(String documentId, String sheetId, String name) async {
    final url = 'https://docs.google.com/spreadsheets/d/$documentId/export?format=csv&id=$documentId&gid=$sheetId';

    var response = await http.get(Uri.parse(url), headers: {'accept': 'text/csv;charset=UTF-8'});

    final bytes = response.bodyBytes.toList();
    final csv = Stream<List<int>>.fromIterable([bytes]);
    final rows = await csv.transform(utf8.decoder).transform(CsvToListConverter(shouldParseNumbers: false)).toList();
    final parser = CsvLocalizationParser();
    final result = parser.parse(input: rows, name: name);
    return result.result;
  }
}
