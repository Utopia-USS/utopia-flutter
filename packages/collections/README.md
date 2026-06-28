<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/collections/docs/header.png" width="276" alt="Utopia Collections"/>

# utopia_collections

Extension methods and small utilities for Dart collections. Re-exports the collection extensions from `fast_immutable_collections` and adds its own helpers across `Iterable`, `List`, `Set`, and `String`:

- **Iterable** - `toSortedList`, `groupBy`, `avgBy`, `firstOrNull` / `findOrNull`, `distinctBy`, `whereNotNull`
- **List** - `tryGet`, `separatedWith`, `minus`, `lastOrNull`
- **Set** - `toggled` (add or remove an element, returning a new set)
- **String** - `nullIfEmpty`
- **Functions** - `anyTrue`, `allTrue` (over an `Iterable<bool>`)
- **Comparator** - `compareBy` for multi-key sorting
