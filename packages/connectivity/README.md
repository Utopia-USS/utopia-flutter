<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/connectivity/docs/header.png" width="292" alt="Utopia Connectivity"/>

# utopia_connectivity

A `utopia_hooks` global state for network connectivity. Wraps [`connectivity_plus`][connectivity_plus]
and exposes the current connectivity status as a reactive state.

## Usage

[`ConnectivityState`][ConnectivityState] is a global state - register
[`useConnectivityState`][useConnectivityState] once in the provider map at your app root:

```dart
const _providers = {
  ConnectivityState: useConnectivityState,
};
```

Then read it from any state hook with [`useProvided`][useProvided]:

```dart
final connectivity = useProvided<ConnectivityState>();
```

[`ConnectivityState`][ConnectivityState] exposes:

- [`result`][result] - the raw `List<ConnectivityResult>?` from `connectivity_plus` (`null` until initialized)
- [`hasConnection`][hasConnection] - `true` when at least one non-`none` result is present
- [`isInitialized`][isInitialized] - `true` once the first connectivity check has completed
- [`awaitInitialized()`][awaitInitialized] - `Future` that resolves once connectivity is known

The state subscribes to `Connectivity().onConnectivityChanged` automatically, so it stays up to date
for as long as the provider is mounted.

[connectivity_plus]: https://pub.dev/packages/connectivity_plus
[ConnectivityState]: https://pub.dev/documentation/utopia_connectivity/latest/utopia_connectivity/ConnectivityState-class.html
[useConnectivityState]: https://pub.dev/documentation/utopia_connectivity/latest/utopia_connectivity/useConnectivityState.html
[useProvided]: https://pub.dev/documentation/utopia_hooks/latest/utopia_hooks/useProvided.html
[result]: https://pub.dev/documentation/utopia_connectivity/latest/utopia_connectivity/ConnectivityState/result.html
[hasConnection]: https://pub.dev/documentation/utopia_connectivity/latest/utopia_connectivity/ConnectivityState/hasConnection.html
[isInitialized]: https://pub.dev/documentation/utopia_connectivity/latest/utopia_connectivity/ConnectivityState/isInitialized.html
[awaitInitialized]: https://pub.dev/documentation/utopia_connectivity/latest/utopia_connectivity/ConnectivityState/awaitInitialized.html
