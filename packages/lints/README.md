<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/lints/docs/header.png" width="212" alt="Utopia Lints"/>

# utopia_lints

Recommended lint rules for Utopia USS projects. Extends `flutter_lints` with strict type-checking and a curated set of additional linter rules.

## Usage

Add to `dev_dependencies` in `pubspec.yaml`:

```yaml
dev_dependencies:
  utopia_lints: ^0.0.5
```

Then in your project's `analysis_options.yaml`, include one of the two rule sets:

| Rule set | File | When to use |
|---|---|---|
| Standard | `lints.yaml` | Applications and most packages |
| Library | `library_lints.yaml` | Published libraries (adds `use_key_in_widget_constructors`) |

```yaml
# For applications / internal packages:
include: package:utopia_lints/lints.yaml

# For published libraries:
include: package:utopia_lints/library_lints.yaml
```
