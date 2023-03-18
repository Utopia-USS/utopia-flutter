import 'package:utopia_arch/src/validation/validator.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

class GenericFieldState<T> {
  final T value;
  final void Function(T value) onChanged;

  final ValidatorResult? errorMessage;

  const GenericFieldState({required this.value, required this.onChanged, this.errorMessage});
}

class MutableGenericFieldState<T> with Validatable<T> implements GenericFieldState<T> {
  final MutableValue<T> _value;
  final MutableValue<ValidatorResult?> _errorMessage;

  const MutableGenericFieldState({required MutableValue<T> value, required MutableValue<ValidatorResult?> errorMessage})
      : _value = value,
        _errorMessage = errorMessage;

  @override
  T get value => _value.value;

  @override
  void Function(T) get onChanged => (value) => _value.value = value;

  set value(T value) => _value.value = value;

  @override
  ValidatorResult? get errorMessage => _errorMessage.value;

  @override
  set errorMessage(ValidatorResult? errorMessage) => _errorMessage.value = errorMessage;
}

typedef FieldState = GenericFieldState<String>;

typedef MutableFieldState = MutableGenericFieldState<String>;

MutableGenericFieldState<T> useGenericFieldState<T>({required T initialValue}) {
  final valueState = useState<T>(initialValue);
  final errorMessageState = useState<ValidatorResult?>(null);

  return useMemoized(
    () => MutableGenericFieldState(
      value: valueState.asMutableValue(),
      errorMessage: errorMessageState.asMutableValue(),
    ),
  );
}

MutableFieldState useFieldState({String initialValue = ""}) => useGenericFieldState(initialValue: initialValue);
