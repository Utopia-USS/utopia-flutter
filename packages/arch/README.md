<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/arch/docs/header.png" width="209" alt="Utopia Arch"/>

# utopia_arch

The all-in-one architecture package for Utopia-based Flutter apps. Adding this single dependency gives you
[`utopia_hooks`][utopia_hooks], [`utopia_widgets`][utopia_widgets], [`utopia_utils`][utopia_utils],
[`utopia_collections`][utopia_collections], [`utopia_validation`][utopia_validation],
[`utopia_reporter`][utopia_reporter], and [`utopia_injector`][utopia_injector] - plus a small set of wiring
utilities that connect them into a working app shell.

## What it adds on top of the bundled packages

### Error handling

[`runWithReporterAndUiErrors(reporter, block)`][runWithReporterAndUiErrors] wraps your `main()` to catch
Flutter framework errors, uncaught `Future` errors, and (on non-Web platforms) unhandled isolate errors.
It forwards everything to a [`Reporter`][Reporter] and simultaneously emits a
[`Stream<UiGlobalError>`][UiGlobalError] your app can listen to for in-UI error display.

```dart
void main() {
  runWithReporterAndUiErrors(reporter, (uiErrors) {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(MyApp(uiErrors: uiErrors));
  });
}
```

You can also implement [`GlobalErrorHandler`][GlobalErrorHandler] directly and call
[`runWithErrorHandler`][runWithErrorHandler] if you need a custom strategy, or compose multiple handlers
with [`GlobalErrorHandler.combine`][GlobalErrorHandler.combine].

### Injector + hooks bridge

[`useInjected<T>()`][useInjected] retrieves a service of type `T` from the [`Injector`][Injector] provided
in the hook context - a one-liner bridge between `utopia_injector` and `utopia_hooks`. A matching
`BuildContext` extension [`context.inject<T>()`][inject] does the same outside of hooks.

### Preferences-backed persisted state

Three hooks built on `utopia_hooks`'s [`usePersistedState`][usePersistedState] + [`SharedPreferences`][shared_preferences]:

- [`usePreferencesPersistedState<T>(key)`][usePreferencesPersistedState] - for `bool`, `int`, `double`, `String`, `List<String>`
- [`useEnumPreferencesPersistedState<T>(key, values)`][useEnumPreferencesPersistedState] - stores an `Enum` as its index
- [`useComplexPreferencesPersistedState<T, T2>(key, toPreferences:, fromPreferences:)`][useComplexPreferencesPersistedState] - custom serialisation

### Extensions

| Extension | Members |
|-----------|---------|
| [`ContextExtensions`][ContextExtensions] on `BuildContext` | [`.navigator`][navigator], [`.routeArgs<T>()`][routeArgs] |
| [`NavigatorExtensions`][NavigatorExtensions] on `NavigatorState` | [`.pushNamedAndReset(route)`][pushNamedAndReset], [`.flow(steps)`][flow] |
| [`ValueNotifierExtensions<T>`][ValueNotifierExtensions] on `ValueNotifier<T>` | [`.modify(block)`][modify], [`.mutate(block)`][mutate], [`.awaitSingle()`][awaitSingle] |
| [`BoolValueNotifierExtensions`][BoolValueNotifierExtensions] on `ValueNotifier<bool>` | [`.toggle()`][toggle] |

### RouteConfig

[`RouteConfig`][RouteConfig] wraps a route's builder and orientation preference together.
[`RouteConfig.material(builder)`][RouteConfig.material] and [`RouteConfig.transparent(builder)`][RouteConfig.transparent]
are the common factories. Pass a `Map<String, RouteConfig>` to [`RouteConfig.generateRoute`][RouteConfig.generateRoute] /
[`RouteConfig.createNavigationObserver`][RouteConfig.createNavigationObserver] to get automatic per-route
orientation locking.

[utopia_hooks]: https://pub.dev/packages/utopia_hooks
[utopia_widgets]: https://pub.dev/packages/utopia_widgets
[utopia_utils]: https://pub.dev/packages/utopia_utils
[utopia_collections]: https://pub.dev/packages/utopia_collections
[utopia_validation]: https://pub.dev/packages/utopia_validation
[utopia_reporter]: https://pub.dev/packages/utopia_reporter
[utopia_injector]: https://pub.dev/packages/utopia_injector
[shared_preferences]: https://pub.dev/packages/shared_preferences
[runWithReporterAndUiErrors]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/runWithReporterAndUiErrors.html
[Reporter]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/Reporter-class.html
[UiGlobalError]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/UiGlobalError-class.html
[GlobalErrorHandler]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/GlobalErrorHandler-class.html
[runWithErrorHandler]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/runWithErrorHandler.html
[GlobalErrorHandler.combine]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/GlobalErrorHandler/combine.html
[useInjected]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/useInjected.html
[Injector]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/Injector-class.html
[inject]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/InjectorBuildContextX/inject.html
[usePersistedState]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/usePersistedState.html
[usePreferencesPersistedState]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/usePreferencesPersistedState.html
[useEnumPreferencesPersistedState]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/useEnumPreferencesPersistedState.html
[useComplexPreferencesPersistedState]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/useComplexPreferencesPersistedState.html
[ContextExtensions]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/ContextExtensions.html
[navigator]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/ContextExtensions/navigator.html
[routeArgs]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/ContextExtensions/routeArgs.html
[NavigatorExtensions]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/NavigatorExtensions.html
[pushNamedAndReset]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/NavigatorExtensions/pushNamedAndReset.html
[flow]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/NavigatorExtensions/flow.html
[ValueNotifierExtensions]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/ValueNotifierExtensions.html
[modify]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/ValueNotifierExtensions/modify.html
[mutate]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/ValueNotifierExtensions/mutate.html
[awaitSingle]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/ValueNotifierExtensions/awaitSingle.html
[BoolValueNotifierExtensions]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/BoolValueNotifierExtensions.html
[toggle]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/BoolValueNotifierExtensions/toggle.html
[RouteConfig]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/RouteConfig-class.html
[RouteConfig.material]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/RouteConfig/RouteConfig.material.html
[RouteConfig.transparent]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/RouteConfig/RouteConfig.transparent.html
[RouteConfig.generateRoute]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/RouteConfig/generateRoute.html
[RouteConfig.createNavigationObserver]: https://pub.dev/documentation/utopia_arch/latest/utopia_arch/RouteConfig/createNavigationObserver.html
