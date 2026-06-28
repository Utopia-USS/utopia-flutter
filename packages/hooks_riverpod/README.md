<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/hooks_riverpod/docs/header.png" width="327" alt="Utopia Hooks Riverpod"/>

# utopia_hooks_riverpod

Utopia Hooks x Riverpod

Bridges `utopia_hooks` and `flutter_riverpod` so that Riverpod providers can be consumed inside hook-based screens. It provides widget base classes that combine both systems and hook functions for reading and watching providers from within the hook context.

## Widgets

| Widget | Description |
|---|---|
| `HookConsumerWidget` | Drop-in replacement for `ConsumerStatefulWidget` that also supports hooks in `build(context, ref)`. |
| `HookConsumer` | Inline builder variant - like `Consumer` but with full hook support. |
| `HookConsumerProviderContainerWidget` | Variant of `HookProviderContainerWidget` (utopia_hooks) that reads Riverpod providers in its `providers` map. Requires `ProviderScope` above it in the tree. |

## Hooks

| Hook | Where available | Description |
|---|---|---|
| `useHookRef()` | All three widgets | Returns a `HookRef` - a safe interface over `WidgetRef` (`watch`, `read`, `listen`, `listenManual`, `refresh`, `invalidate`, `exists`). |
| `useHookConsumerRef()` | `HookConsumer` / `HookConsumerWidget` only | Returns `HookConsumerRef`, which additionally exposes the underlying `WidgetRef` via `.widgetRef`. |
| `useRefWatch(provider)` | All three widgets | Convenience shorthand for `useHookRef().watch(provider)`. |

## Usage

```dart
// Extend HookConsumerWidget instead of ConsumerStatefulWidget + StatefulHookWidget
class MyWidget extends HookConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, HookConsumerRef ref) {
    // Watch a Riverpod provider - rebuilds on change
    final value = useRefWatch(myProvider);

    // Use any utopia_hooks hooks alongside it
    final state = useMyHookState();

    return Text('$value');
  }
}
```

```dart
// Or use HookConsumer inline
HookConsumer(
  builder: (context, ref) {
    final value = useRefWatch(myProvider);
    return Text('$value');
  },
)
```
