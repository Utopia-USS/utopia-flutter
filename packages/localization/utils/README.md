<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/localization/utils/docs/header.png" width="343" alt="Utopia Localization Utils"/>

# utopia_localization_utils

Flutter runtime helpers for
[utopia_localization_generator](https://pub.dev/packages/utopia_localization_generator). Provides
the delegate and utilities needed to wire generated localization classes into a Flutter app.

## What's included

**`UtopiaLocalizationsDelegate<T>`** - a `LocalizationsDelegate` that wraps a
`UtopiaLocalizationData<T>` map (produced by the generator). Pass it to
`MaterialApp.localizationsDelegates`.

**`LocalizationMapLocaleExtensions`** - extension on `UtopiaLocalizationData<T>`:
- `supportedLocales` - derives a `Set<Locale>` from the data map's language-tag keys
- `operator []` - looks up a localization instance by `Locale`

**`localeFromLanguageTag(String)`** - converts a BCP 47 language tag (e.g. `"en-US"`,
`"zh-Hans-CN"`) into a `Locale`.

**`BuildContextLocalizationsExtensions`** - extension on `BuildContext`:
- `context.localizations<T>()` - shorthand for `Localizations.of<T>(context, T)!`

## Usage

```dart
// In your MaterialApp:
MaterialApp(
  locale: currentLocale,
  supportedLocales: myStrings.supportedLocales,
  localizationsDelegates: [
    UtopiaLocalizationsDelegate(myStrings),
    ...GlobalMaterialLocalizations.delegates,
  ],
);

// In a widget:
final strings = context.localizations<MyStrings>();
```
