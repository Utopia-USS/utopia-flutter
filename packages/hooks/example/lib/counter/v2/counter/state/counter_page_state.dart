import 'package:utopia_hooks/utopia_hooks.dart';

class CounterPageState {
  final int value;
  final void Function() onPressed;

  const CounterPageState({required this.value, required this.onPressed});
}

CounterPageState useCounterPageState() {
  final state = useState(0);

  return CounterPageState(
    value: state.value,
    onPressed: () => state.value++,
  );
}
