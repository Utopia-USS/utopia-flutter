<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/collections/docs/header.png" width="276" alt="Utopia Collections"/>

# utopia_collections

Extension methods and small utilities for Dart collections. Re-exports the collection extensions from `fast_immutable_collections` and adds its own helpers across `Iterable`, `List`, `Set`, and `String`:

- **Iterable** - [`toSortedList`][toSortedList], [`groupBy`][groupBy], [`avgBy`][avgBy], [`firstOrNull`][firstOrNull] / [`findOrNull`][findOrNull], [`distinctBy`][distinctBy], [`whereNotNull`][whereNotNull]
- **List** - [`tryGet`][tryGet], [`separatedWith`][separatedWith], [`minus`][minus], [`lastOrNull`][lastOrNull]
- **Set** - [`toggled`][toggled] (add or remove an element, returning a new set)
- **String** - [`nullIfEmpty`][nullIfEmpty]
- **Functions** - [`anyTrue`][anyTrue], [`allTrue`][allTrue] (over an `Iterable<bool>`)
- **Comparator** - [`compareBy`][compareBy] for multi-key sorting

[toSortedList]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/IterableExtension/toSortedList.html
[groupBy]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/IterableExtension/groupBy.html
[avgBy]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/IterableExtension/avgBy.html
[firstOrNull]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/IterableExtension/firstOrNull.html
[findOrNull]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/IterableExtension/findOrNull.html
[distinctBy]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/IterableExtension/distinctBy.html
[whereNotNull]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/IterableExtensionNullable/whereNotNull.html
[tryGet]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/ListExtensions/tryGet.html
[separatedWith]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/ListExtensions/separatedWith.html
[minus]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/ListExtensions/minus.html
[lastOrNull]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/ListExtensions/lastOrNull.html
[toggled]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/SetExtensions/toggled.html
[nullIfEmpty]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/StringExtensions/nullIfEmpty.html
[anyTrue]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/anyTrue.html
[allTrue]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/allTrue.html
[compareBy]: https://pub.dev/documentation/utopia_collections/latest/utopia_collections/compareBy.html
