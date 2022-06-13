# utopia_hooks

Basic and complex hooks (including SubmitState, ComputedState and supporting widgets).

## Highlights

### ComputedState

Designed for cases where global/local state is asynchronously fetched, possibly based on some input data. Provides error
handling, cancellation, previous value memoization, deduplication, manual updates and more. Also, via
its `useAutoComputedState` variant, supports automatic re-fetching (`keys`), debouncing (`debounceDuration`) and
conditional computation (`shouldCompute`).

#### ComputedWrapper widget family

Convenience widgets for consuming `ComputedState`s in UI. Has variants for refreshable and non-refreshable states with
simple or list-based values

### SubmitState

Designed for cases where user action triggers some asynchronous operation. Supports two usage modes: first, bare-bones
and flexible (`submitState.run(operation)`) and second, opinionated and convenient (`submitState.runSimple(...)`).
Supports parallel submits, error handling, retrying and more.

### HookStateProviderWidget

Combination of `HookWidget` and `Provider`, designed for hook-based global states. Can be used with `MultiProvider`.

### useSimpleEffect

Similar to `useEffect`, but executes outside the build phase, which fixes common `setState`-during-build bugs.

### useValueWrapper

Simple hook that helps combat memoization issues. Basically a `useRef` which updates its value on every rebuild. Use in
hooks that take functional arguments.  
See [`useAppLifecycleStateCallbacks`](lib/src/hook/misc/use_app_lifecycle_state_callbacks.dart) for an example.
