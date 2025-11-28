## 0.4.20

 - **FEAT**(utopia_injector): Init package.

## 0.4.19+3

 - **FIX**(utopia_hooks): Skip if in progress on useSubmitButtonState.

## 0.4.19+2

 - **FIX**(utopia_hooks): Fix lazy initialization issues in HookProviderContainerMixin.

## 0.4.19+1

 - **FIX**(utopia_hooks): Remove HasInitialized equality.

## 0.4.19

 - **FEAT**(utopia_hooks,utopia_hooks_riverpod): Add alwaysNotifyDependents.

## 0.4.18+1

 - **FIX**: Adjust utopia_lints.

## 0.4.18

 - **FEAT**(utopia_hooks): Add ButtonState.

## 0.4.17+2

 - **FIX**(utopia_hooks): useStreamSubscription: Fix edge case when disposing.

## 0.4.17+1

 - **FIX**(utopia_hooks): Improve error handling in HookProviderContainer.

## 0.4.17

 - **FEAT**(utopia_hooks): Add useWithSelfOrNull.

## 0.4.16

 - **FEAT**(utopia_hooks): Add listen parameter to useNotifiable.

## 0.4.15+1

 - **FIX**(utopia_hooks): Fix TextEditingControllerWrapper when underlying MutableValue instance changes.

## 0.4.15

 - **FEAT**(utopia_hooks): Improvements to ListenableValue.

## 0.4.14

 - **FEAT**: Upgrade packages.

## 0.4.13

 - **FEAT**(utopia_hooks): Allow ProviderContext to be keyed by any object.

## 0.4.12+1

 - **FIX**(utopia_hooks): Fix addPostBuildCallback when no hook has been used yet.

## 0.4.12

 - **FIX**(utopia_hooks): Fix diagnostics in NestedHookState.
 - **FEAT**(utopia_hooks): Add useLet.

## 0.4.11

 - **FEAT**(utopia_hooks): Add NotifiableValue default impl.

## 0.4.10

 - **FEAT**(utopia_hooks): Add async capabilities to useStreamSubscription.

## 0.4.9+1

 - **FIX**(utopia_hooks): Fix _ProviderBuildContext.

## 0.4.9

 - **FEAT**(utopia_hooks): Add possibility to read values from ProviderContext without watching.

## 0.4.8+1

 - **FIX**(utopia_hooks): Fix tests.

## 0.4.8

 - **FEAT**(utopia_hooks): Add useKeyed.

## 0.4.7+1

 - **FIX**(utopia_hooks): Fix NotifiableValue mapping.

## 0.4.7

 - **FEAT**(utopia_hooks): Add NotifiableValue mapping.

## 0.4.6+1

 - **FIX**(utopia_hooks): Fix exports.

## 0.4.6

 - **FEAT**(utopia_hooks): Add Notifiable and related hooks.

## 0.4.5+2

 - **FIX**(utopia_hooks): Fix signatures of async hooks.

## 0.4.5+1

 - **FIX**(utopia_hooks_riverpod): Fix exports.

## 0.4.5

 - **FIX**(utopia_hooks): Expose HookProviderContainerWidgetMixin and HookProviderContainerWidgetStateMixin.
 - **FEAT**(utopia_hooks_riverpod): Add HookConsumerProviderContainerWidget.

## 0.4.4+7

 - **FIX**(utopia_hooks): Fix bug in HookWidget during multi-rebuilds.

## 0.4.4+6

 - **FIX**(utopia_hooks): Allow for multiple builds per frame in HookWidget.

## 0.4.4+5

 - **FIX**(utopia_hooks): Improve error handling.

## 0.4.4+4

 - **FIX**(utopia_hooks): Fix useEffect.

## 0.4.4+3

 - **FIX**(utopia_hooks): Fix HookContextStateMixin.

## 0.4.4+2

 - **FIX**(utopia_hooks): Fix useCombinedInitializationState.

## 0.4.4+1

 - **FIX**(utopia_hooks): Fix useMemoized.

## 0.4.4

 - **FIX**(utopia_hooks): Update dependencies.
 - **FIX**(utopia_collections): Update dependencies.
 - **FEAT**(utopia_hooks): Implement diagnostics.

## 0.4.3+9

 - Update a dependency to the latest release.

## 0.4.3+8

 - **FIX**(utopia_hooks): Fix memoization issue in usePersistedState.

## 0.4.3+7

 - **FIX**(utopia_hooks): Export useAsyncSnapshotErrorHandler.

## 0.4.3+6

 - **FIX**(utopia_hooks): Fix HookProviderContainerWidget.

## 0.4.3+5

 - **FIX**(utopia_hooks): Fix HookProviderContainer.waitUntil.

## 0.4.3+4

 - **FIX**(utopia_hooks): Remove unnecessary check in HookProviderContainer refresh.

## 0.4.3+3

 - **FIX**(utopia_hooks): Fix SimpleHookProviderContainer.

## 0.4.3+2

 - **FIX**(utopia_hooks): Fix SimpleHookContext and SimpleHookProviderContainer.

## 0.4.3+1

 - **FIX**(utopia_hooks): Check for isMounted in usePeriodicalSignal.

## 0.4.3

 - **FEAT**(utopia_hooks): Improve useListenable/useValueListenable hooks to allow for selective rebuilding.

## 0.4.2

 - **FEAT**(utopia_hooks_riverpod): Initial release.
 - **FEAT**(utopia_hooks): Expose HookContextStateMixin.

## 0.4.1

 - **FIX**(utopia_hooks): Export src/misc/listenable_value.dart.
 - **FIX**(utopia_hooks): Fix ProviderWidget.updateShouldNotify.
 - **FEAT**(utopia_hooks): Add `init` parameter to SimpleHookContext constructor.
 - **FEAT**(utopia_hooks): Extract ProviderContext, add CombinedInitializationState.

## 0.4.0+4

 - **FIX**(utopia_hooks): README.

## 0.4.0+3

 - **FIX**(utopia_hooks): README.

## 0.4.0+2

 - **FIX**(utopia_hooks): README.

## 0.4.0+1

 - **FIX**(utopia_hooks): README.

## 0.4.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 0.4.0-dev.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: Decouple hooks and prepare architecture v2.

## 0.3.12+1

 - Update a dependency to the latest release.

## 0.3.12

 - **FEAT**(utopia_arch): Make PersistedState implement MutableValue.

## 0.3.11

 - **FEAT**(utopia_hooks): Add skipIfInProgress to SubmitState.runSimple.

## 0.3.10

 - **FEAT**(utopia_hooks): Add child to HookStateProvider.

## 0.3.9+5

 - **FIX**(utopia_hooks): Fix initial value in StatelessTextEditingControllerWrapper.

## 0.3.9+4

 - Update a dependency to the latest release.

## 0.3.9+3

 - Update a dependency to the latest release.

## 0.3.9+2

 - Update a dependency to the latest release.

## 0.3.9+1

 - Update a dependency to the latest release.

## 0.3.9

 - **FEAT**: Add StatelessTextControllerWrapper.mutableValue.

## 0.3.8+1

 - **FIX**: Export useMemoizedIf.

## 0.3.8

 - **FEAT**: Add useMemoizedIf.

## 0.3.7+2

 - Update a dependency to the latest release.

## 0.3.7+1

 - **FIX**: Export usePeriodicalSignal.

## 0.3.7

 - **FEAT**: Add StatelessTextControllerWrapper.controllerProvider.

## 0.3.6+3

 - Update a dependency to the latest release.

## 0.3.6+2

 - Update a dependency to the latest release.

## 0.3.6+1

 - **FIX**: Fix SubmitState shouldSubmit condition.

## 0.3.6

 - **FEAT**: Memoize PersistedState.

## 0.3.5+4

 - **FIX**: Change PersistedState argument order.

## 0.3.5+3

 - **FIX**: Export PersistedState.

## 0.3.5+2

 - Update a dependency to the latest release.

## 0.3.5+1

 - Update a dependency to the latest release.

## 0.3.5

 - **FEAT**: Cleanup, add usePeriodicalSignal, add HookStateProvider.

## 0.3.4+1

 - Update a dependency to the latest release.

## 0.3.4

 - **FEAT**: Fix useValueListenableListener memoization issue.

## 0.3.3+2

 - Update a dependency to the latest release.

## 0.3.3+1

 - **FIX**: Update exports.

## 0.3.3

 - **FEAT**: Add useDebounced, usePreviousIfNull and useWithSelf.

## 0.3.2+11

 - Update a dependency to the latest release.

## 0.3.2+10

 - Update a dependency to the latest release.

## 0.3.2+9

 - Update a dependency to the latest release.

## 0.3.2+8

 - Update a dependency to the latest release.

## 0.3.2+7

 - Update a dependency to the latest release.

## 0.3.2+6

 - Update a dependency to the latest release.

## 0.3.2+5

 - Update a dependency to the latest release.

## 0.3.2+4

 - Update a dependency to the latest release.

## 0.3.2+3

 - Update a dependency to the latest release.

## 0.3.2+2

 - Update a dependency to the latest release.

## 0.3.2+1

 - **FIX**: ensure isMounted in useSubmitState.

## 0.3.2

 - **FIX**: Add documentation.
 - **FEAT**: Update Flutter to 3.0.0.
 - **FEAT**: Add .cleared state to ComputedStateValue; extract ComputedIterableWrapper.

## 0.3.1+2

 - **FIX**: fix useStreamSubscription memoization issue.

## 0.3.1+1

 - Update a dependency to the latest release.

## 0.3.1

 - **FEAT**: additional provider capabilities; deprecate use_togglable_bool.

## 0.3.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: rebuild SubmitState and move to global unknown error handling mechanisms.

## 0.2.8

 - **FIX**: separate library_lints.yaml.
 - **FEAT**: adhere to lints.
 - **FEAT**: adhere to lints.

## 0.2.7

 - **FEAT**: adhere to lints.

## 0.2.6+3

 - **FIX**: clear computation on debounce in useAutoComputedState.

## 0.2.6+2

 - **FIX**: fix useAppLifecycleStateCallbacks.onResumed being called too often.

## 0.2.6+1

 - **FIX**: fix initial value of StatelessTextControllerWrapper.

## 0.2.6

 - **FEAT**: add keepInProgress parameter to ComputedStateWrappers.

## 0.2.5+2

 - **FIX**: Fix memoization issue in StatelessTextControllerWrapper.
 - **CHORE**: publish packages.

## 0.2.5+1

 - **FIX**: export IList variants of ComputedStateWrapper's.

## 0.2.5

 - **FEAT**: add IList variants of ComputedStateWrapper's.

## 0.2.4+5

 - Update a dependency to the latest release.

## 0.2.4+4

 - Update a dependency to the latest release.

## 0.2.4+3

 - Update a dependency to the latest release.

## 0.2.4+2

 - Update a dependency to the latest release.

## 0.2.4+1

 - **FIX**: relax async package version constraint.

## 0.2.4

 - **FEAT**: create SubmitState.combine.

## 0.2.3+1

 - Update a dependency to the latest release.

## 0.2.3

 - **FEAT**: add [Refreshable]ComputedStateWrapper.

## 0.2.2+1

 - Update a dependency to the latest release.

## 0.2.2

 - **FEAT**: add ComputedState.valueOrPreviousOrNull.

## 0.2.1+5

 - **FIX**: fix memoization in useStreamSubscription.

## 0.2.1+4

 - **FIX**: fix useAppLifecycleStateCallbacks.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 0.2.1+3

 - **FIX**: export flutter_hooks for import convenience.

## 0.2.1+2

 - Update a dependency to the latest release.

## 0.2.1+1

 - **FIX**: Add isMounted checks in ComputedState and SubmitState.

## 0.2.1

 - **FEAT**: Add ComputedStateValue.mapValue.

## 0.2.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: Fix directory structure.

## 0.1.1+1

 - **FIX**: improve import convenience.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 0.1.1

 - **FEAT**: update Reporter usages.

## 0.1.0

> Note: This release has breaking changes.

 - **FIX**: log unhandled exceptions in MutableComputedState.refresh.
 - **FIX**: improve import convenience of SubmitStateExtensions.
 - **BREAKING** **FEAT**: redesign ComputedState to use ComputedStateValue.

## 0.0.2

 - **FEAT**: Initial commit.

## [0.0.1] Initial release