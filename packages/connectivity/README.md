<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/connectivity/docs/header.png" width="292" alt="Utopia Connectivity"/>

# utopia_connectivity

A `utopia_hooks` global state for network connectivity. Wraps `connectivity_plus` and exposes the
current connectivity status as a reactive hook.

## Usage

Call `useConnectivityState()` inside a hook-based screen or state. It returns a `ConnectivityState`
with:

- `result` - the raw `List<ConnectivityResult>?` from `connectivity_plus` (`null` until initialized)
- `hasConnection` - `true` when at least one non-`none` result is present
- `isInitialized` - `true` once the first connectivity check has completed
- `awaitInitialized()` - `Future` that resolves once connectivity is known

```dart
final connectivity = useConnectivityState();

if (!connectivity.isInitialized) return const LoadingView();
if (!connectivity.hasConnection) return const OfflineBanner();
```

The hook subscribes to `Connectivity().onConnectivityChanged` automatically, so the state stays
up to date while the widget is mounted.