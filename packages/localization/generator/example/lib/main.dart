import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:utopia_localization_annotation/utopia_localization_annotation.dart';
import 'package:utopia_localization_utils/utopia_localization_utils.dart';

import 'localizations.dart';

void main() => runApp(const MyApp());

extension AppLocalizationsExtensions on BuildContext {
  AppLocalizationsData get strings => localizations();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _currentLocale;
  UtopiaLocalizationData<AppLocalizationsData>? _override;

  @override
  void initState() {
    _currentLocale = appLocalizationsData.supportedLocales.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      locale: _currentLocale,
      localizationsDelegates: [
        UtopiaLocalizationsDelegate<AppLocalizationsData>(_override ?? appLocalizationsData),
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: appLocalizationsData.supportedLocales,
      // <- Supported locales
      home: MyHomePage(
        title: 'Internationalization demo',
        locale: _currentLocale,
        onLocaleChanged: (locale) {
          if (_currentLocale != locale) {
            setState(() => _currentLocale = locale);
          }
        },
        onImportPressed: _upload,
      ),
    );
  }

  Future<void> _upload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result != null) {
      final data = result.files.single.bytes!;
      final json = jsonDecode(utf8.decode(data));
      setState(() => _override = UtopiaLocalizationData.fromJson(json as Map<String, dynamic>, AppLocalizationsData.fromJson));
    }
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, 
    required this.title,
    required this.locale,
    required this.onLocaleChanged,
    required this.onImportPressed,
  });

  final String title;
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
  final void Function() onImportPressed;

  @override
  Widget build(BuildContext context) {
    final labels = context.strings; // <- Accessing your labels
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [IconButton(icon: const Icon(Icons.upload), onPressed: onImportPressed)],
      ),
      body: Column(
        children: <Widget>[
          DropdownButton<Locale>(
            key: const Key('Picker'),
            value: locale,
            items: appLocalizationsData.supportedLocales.map((locale) {
              return DropdownMenuItem<Locale>(
                value: locale,
                child: Text(
                  locale.toString(),
                ),
              );
            }).toList(),
            onChanged: (locale) {
              if (locale != null) onLocaleChanged(locale);
            },
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Text(labels.dates.month.february),
                Text(labels.multiline),
                Text(labels.templated.hello(firstName: 'World')),
                Text(labels.templated.contact(Gender.male, lastName: 'John')),
                Text(labels.templated.contact(Gender.female, lastName: 'Jane')),
                Text('0 ${labels.plurals.man(0.plural())}'),
                Text('1 ${labels.plurals.man(1.plural())}'),
                Text('5 ${labels.plurals.man(5.plural())}'),
                Text(labels.templated.numbers.simple(price: 10)),
                Text(labels.templated.numbers.formatted(price: 10)),
                Text(labels.templated.date.simple(date: DateTime.now())),
                Text(labels.templated.date.pattern(date: DateTime.now())),
              ],
              // Displaying templated label
            ),
          ),
        ],
      ),
    );
  }
}
