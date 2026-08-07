<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/platform_utils/docs/header.png" width="308" alt="Utopia Platform Utils"/>

# utopia_platform_utils

Shared Kotlin and Swift utilities for writing Flutter plugins. There is no Dart-facing API - this package is a dependency for other Utopia Flutter plugins that contain Android or iOS platform code.

## Android utilities

**`BaseFlutterPlugin`** - Abstract base class for Flutter plugins that need activity awareness and coroutine scopes. Handles `FlutterPlugin` + `ActivityAware` + `ActivityResultListener` lifecycle, providing:
- `binding` / `context` - plugin binding and application context
- `activityBinding` / `activity` - current activity binding and activity
- `activityScope` - a `CoroutineScope` tied to the activity lifecycle (cancelled on detach)
- `activityResultEvents: Flow<ActivityResult>` - a Flow of `onActivityResult` callbacks for the request codes listed in `activityRequestCodes`

**Coroutine utilities**
- `RestartableCoroutineScope` - a `CoroutineScope` that can be opened and cancelled repeatedly via `openScope()` / `closeScope()`, used internally by `BaseFlutterPlugin`
- `scopedLazy` / `scopedDelegate` - `ReadOnlyProperty` helpers that lazily create a value and reset it when the coroutine scope is cancelled

**Method channel helpers**
- `runForResult(result, block)` - runs a synchronous block and calls `result.success` / `result.error` automatically
- `CoroutineScope.launchForResult(result, block)` - launches a coroutine and pipes its return value (or any thrown exception) to a `MethodChannel.Result`

**Serialization**
- `Json.encodeToFlutter(serializer, value)` / `Json.decodeFromFlutter(serializer, value)` - convert between `kotlinx-serialization-json` types and the `Any?` map/list/primitive format that Flutter method channels use. Requires `kotlinx-serialization-json` on the classpath.

**Delegate utilities**
- `GenericReadOnlyDelegate` - a simple `ReadOnlyProperty` backed by a lambda
- `Lazy<T>.delegate` - adapter that wraps a `Lazy<T>` as a `ReadOnlyProperty`

