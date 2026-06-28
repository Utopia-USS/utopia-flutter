<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/arch/docs/header.png" width="209" alt="Utopia Arch"/>

# utopia_arch

The all-in-one architecture package for Utopia-based Flutter apps. Adding this single dependency gives you
`utopia_hooks`, `utopia_widgets`, `utopia_utils`, `utopia_collections`, `utopia_validation`, `utopia_reporter`,
and `utopia_injector` - plus a small set of wiring utilities that connect them into a working app shell.

## What it adds on top of the bundled packages

### Error handling

`runWithReporterAndUiErrors(reporter, block)` wraps your `main()` to catch Flutter framework errors, uncaught
`Future` errors, and (on non-Web platforms) unhandled isolate errors. It forwards everything to a `Reporter`
and simultaneously emits a `Stream<UiGlobalError>` your app can listen to for in-UI error display.

```dart
void main() {
  runWithReporterAndUiErrors(reporter, (uiErrors) {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(MyApp(uiErrors: uiErrors));
  });
}
```

You can also implement `GlobalErrorHandler` directly and call `runWithErrorHandler` if you need a custom strategy,
or compose multiple handlers with `GlobalErrorHandler.combine`.

### Injector + hooks bridge

`useInjected<T>()` retrieves a service of type `T` from the `Injector` provided in the hook context - a
one-liner bridge between `utopia_injector` and `utopia_hooks`. A matching `BuildContext` extension
`context.inject<T>()` does the same outside of hooks.

### Preferences-backed persisted state

Three hooks built on `utopia_hooks`'s `usePersistedState` + `SharedPreferences`:

- `usePreferencesPersistedState<T>(key)` - for `bool`, `int`, `double`, `String`, `List<String>`
- `useEnumPreferencesPersistedState<T>(key, values)` - stores an `Enum` as its index
- `useComplexPreferencesPersistedState<T, T2>(key, toPreferences:, fromPreferences:)` - custom serialisation

### Extensions

| Extension | Members |
|-----------|---------|
| `ContextExtensions` on `BuildContext` | `.navigator`, `.routeArgs<T>()` |
| `NavigatorExtensions` on `NavigatorState` | `.pushNamedAndReset(route)`, `.flow(steps)` |
| `ValueNotifierExtensions<T>` on `ValueNotifier<T>` | `.modify(block)`, `.mutate(block)`, `.awaitSingle()` |
| `BoolValueNotifierExtensions` on `ValueNotifier<bool>` | `.toggle()` |

### RouteConfig

`RouteConfig` wraps a route's builder and orientation preference together.
`RouteConfig.material(builder)` and `RouteConfig.transparent(builder)` are the common factories.
Pass a `Map<String, RouteConfig>` to `RouteConfig.generateRoute` / `RouteConfig.createNavigationObserver`
to get automatic per-route orientation locking.
