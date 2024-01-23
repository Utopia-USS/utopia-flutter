
<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/hooks/docs/logo.png" height="160px" alt="Logo"/>

Visit [hooks.utopiasoft.io](https://hooks.utopiasoft.io)

# Overview

Goal of this package is to provide a comprehensive but flexible state management solution for Flutter apps. It's heavily
inspired by React Hooks (and [Flutter Hooks](https://pub.dev/packages/flutter_hooks)), but takes a more holistic
approach, allowing hooks to be used in various contexts, covering all use-cases required for a complete mobile
application
architecture including not only local, but also global states, as well as unit & integration-testing.

## Hooks

Hooks are functions that represent a single piece of state (or business logic). They return a value that can be
then used in UI or other hooks and can request to be rebuilt (like `setState` in `StatefulWidget`s).

<p align="center">
  <img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/hooks/docs/single_hook.png" style="max-height: 300px" alt="Single hook"/>
</p>

The three most basic hooks are:

- `useState` which represents a single, mutable value of any type (e.g. the current value of a switch)
- `useEffect` which represents a side effect that can happen in reaction to changing state (e.g. fetching data
  from the internet when the search field content changes). Effect can optionally return a "dispose" function which
  will be called when the effect is removed (e.g. to cancel the network request).

The simplest way to start using hooks is via `HookWidget` which is like a `StatelessWidget`, but with the possibility to
call hooks in its `build` method:

```dart
class CounterButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // Create a mutable state of type `int` with an initial value of 0
    final counter = useState(0);

    // Register a side-effect
    useEffect(() {
      print('Counter changed to ${counter.value}'); // <- This will print whenever value of `counter` changes
    }, [counter.value]); // <- The "keys" of the effect; it executes when any of them changes.

    // Register a one-time side-effect
    useEffect(() {
      print('Counter created'); // <- This will print once when the widget is created.

      // Return the "dispose" function which will be called when this effect is removed.
      return () => print('Counter destroyed'); // <- This will print once when the widget is destroyed.
    }); // <- No keys is equivalent to empty dependencies - the effect will only run once.

    return ElevatedButton(
      child: Text('Counter: ${counter.value}'), // Access the current value of the state.
      onPressed: () => counter.value++, // Update the value of the state in reaction to user interaction.
    );
  }
}
```

## Hook rules

Using hooks is simple, but there are a few rules that need to be followed:

1. Hooks MUST be called directly in supported places (like the `build` method of a `HookWidget`), or in other
   hooks. Directly - meaning that they cannot be called in callbacks (like `onPressed` of a `ElevatedButton`).
2. Hooks CAN'T be called in `if` statements or in loops. Essentially, the same set of hooks must be called in the same
   order on every build.
3. Hooks SHOULD start with `use` prefix. This is a convention that makes it easier to distinguish hooks from other
   functions.
4. Hooks SHOULD operate on and return immutable objects. This makes it easier to reason about the code and prevents
   accidental bugs.

## Composing hooks

Hooks are composable, meaning that more complex hooks can be built from simpler ones. This is similar to how `Widget`s
are composed to create arbitrarily complex UIs. Using this principle, a single `useCounterState` hook can be extracted
from the previous example:

```dart
// Immutable object representing the state of a counter.
class CounterState {
  final int value;
  final void Function() onPressed; // An action to be called when the button is pressed.

  const CounterState({required this.value, required this.onPressed});
}

// A hook that returns a `CounterState` object.
CounterState useCounterState() {
  final counter = useState(0);

  useEffect(() {
    print('Counter changed to ${counter.value}');
  }, [counter.value]);

  return CounterState(
    value: counter.value,
    onPressed: () => counter.value++,
  );
}

class CounterButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = useCounterState();

    return ElevatedButton(
      child: Text('Counter: ${state.value}'),
      onPressed: state.onPressed,
    );
  }
}
```

## See also

- [Hooks basics](https://hooks.utopiasoft.io/guides/basics) - Introduction to using hooks.
- [Common hooks](https://hooks.utopiasoft.io/guides/common_hooks) - A list of most common hooks with an in-depth
  explanation.

# Hook-based Architecture

While hooks can be used as a simple replacement for `StatefulWidget`s, they are much more powerful when used as a
foundation of the architecture of the whole app. `utopia_hooks` package contains everything needed to build a scalable
app architecture based on hooks.

## Local state

"Local state" refers to the presentation logic of single screen or widget. It's usually consists of the following
components:

1. **State** class which contains the entirety of the state of the component and actions (functions) that can be
   performed on it
2. **Hook** which returns the State and reacts to its actions
3. **View** which displays the UI based on the current state and triggers the actions based e.g. on the user input
4. **Coordinator** which serves as an entry point for the component by binding the Hook and View together and providing
   external functionality, like navigation.

<p align="center">
  <img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/hooks/docs/local_state.png" style="max-height: 350px" alt="Local state"/>
</p>

```dart
// State
class MyScreenState {
  final int someValue;

  // ... additional state

  final void Function() onSomethingPressed;

  // ... additional actions

  const MyScreenState(/* ... */);
}

// Hook
MyScreenState useMyScreenState({required MyScreenArgs args, required void Function() moveToOtherScreen}) {
  // ... logic of the screen

  return MyScreenState(/* ... */);
}

// View
class MyScreenView extends StatelessWidget {
  final MyScreenState state;

  const MyScreenView(this.state);

  @override
  Widget build(BuildContext context) {
    // ...
  }
}

// Coordinator
class MyScreen extends HookWidget {
  const MyScreen();

  @override
  Widget build(BuildContext context) {
    final state = useMyScreenState(
      args: ModalRoute
          .of(context)!
          .settings
          .arguments as MyScreenArgs,
      moveToOtherScreen: () => Navigator.of(context).push(/* ... */),
    );

    return MyScreenView(state);
  }
}
```

### See also

- [Local state](https://hooks.utopiasoft.io/guides/architecture/local_state) - An in-depth guide on implementing
  local state using hooks.
- [Unit testing](https://hooks.utopiasoft.io/guides/architecture/testing#unit-testing) - A guide on unit-testing local
  state hooks.

## Global state

"Global state" refers to any logic shared throughout the whole app, e.g. authentication, database management or user
settings. It's convenient to break this logic up into smaller pieces ("Global states"), adhering to the Single
Responsibility Principle. Each one can be represented by a standalone hook, and then can be depended on by other global
or local states.

<p align="center">
  <img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/hooks/docs/global_state.png" style="max-height: 450px"  alt="Utopia Hooks States Diagram">
</p>

### Creating global states

A global state is very similar to a local state, but without the View and Coordinator:

```dart
class AuthState {
  final User? user;
  final Future<void> Function(User) logIn;
  final Future<void> Function() logOut;

  const AuthState(/* ... */);

  bool get isLoggedIn => user != null;
}

AuthState useAuthState() {
  final userState = useState<User?>(null);

  Future<void> logIn() async {
    // ...
  }

  Future<void> logOut() async {
    // ...
  }

  return AuthState(user: userState.value, logIn: logIn, logOut: logOut);
}
```

### Consuming global states

A dependency on a global state is created using the `useProvided` hook, which causes the hook to be rebuilt whenever any
of the dependencies change. This allows higher-level global states to depend on lower-level ones, creating a hierarchy
of dependencies with local states at the bottom.
It's recommended to place `useProvided` calls together at the top of the hook, making it easier to reason about the
structure of the dependencies:

```dart
// Either global or local state hook
MyState useMyState() {
  final stateA = useProvided<StateA>();
  final stateB = useProvided<StateB>();

  // ... rest of the logic
}
```

### Registering global states

Global states are usually registered by wrapping the `MaterialApp` in `HookProviderContainerWidget`:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HookProviderContainerWidget(
      providers: {
        AuthState: useAuthState,
        // ... other global states
      },
      child: MaterialApp(
        // ...
      ),
    );
  }
}
```

### See also

- [Global state](https://hooks.utopiasoft.io/guides/architecture/global_state) - An in-depth guide on
  implementing global state using hooks.
- [Integration testing](https://hooks.utopiasoft.io/guides/architecture/testing#integration-testing) - A guide on
  integration-testing global and local states.

# Examples

- [Counter v1](example/lib/counter/v1) - "Counter" example (bare-bones)
- [Counter v2](example/lib/counter/v2) - "Counter" example (using Hook-based architecture)
- [Search - Firestore](example/lib/search/firebase) - Dynamic list with search and real-time updates, based on Firebase
  Firestore
- [Search - Clean Architecture](example/lib/search/clean) - Dynamic list with search, based on Clean Architecture.
- [Form Validation](example/lib/form_validation) - Complex form with validation,
  using [`utopia_validation`](https://pub.dev/packages/utopia_validation).