import 'package:utopia_hooks/src/hook/base/use_memoized.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_utils/utopia_utils.dart';
import 'package:utopia_validation/utopia_validation.dart';

abstract interface class GenericFieldState<T> implements MutableValue<T>, HasErrorMessage {
  const factory GenericFieldState({required MutableValue<T> value, required ValidatorResult? errorMessage}) =
      GenericFieldStateImpl;
}

abstract interface class MutableGenericFieldState<T> implements GenericFieldState<T>, Validatable<T> {
  const factory MutableGenericFieldState({
    required MutableValue<T> value,
    required MutableValue<ValidatorResult?> errorMessage,
  }) = MutableGenericFieldStateImpl;
}

final class GenericFieldStateImpl<T> extends DelegateMutableValue<T> implements GenericFieldState<T> {
  @override
  final ValidatorResult? errorMessage;

  const GenericFieldStateImpl({required MutableValue<T> value, required this.errorMessage}) : super(value);
}

final class MutableGenericFieldStateImpl<T> extends DelegateMutableValue<T> implements MutableGenericFieldState<T> {
  final MutableValue<ValidatorResult?> _errorMessage;

  const MutableGenericFieldStateImpl({
    required MutableValue<T> value,
    required MutableValue<ValidatorResult?> errorMessage,
  })  : _errorMessage = errorMessage,
        super(value);

  @override
  ValidatorResult? get errorMessage => _errorMessage.value;

  @override
  set errorMessage(ValidatorResult? value) => _errorMessage.value = value;
}

typedef FieldState = GenericFieldState<String>;

typedef MutableFieldState = MutableGenericFieldState<String>;

MutableGenericFieldState<T> useGenericFieldState<T>({required T initialValue}) {
  final valueState = useState<T>(initialValue);
  final errorMessageState = useState<ValidatorResult?>(null);

  return useMemoized(() => MutableGenericFieldState(value: valueState, errorMessage: errorMessageState));
}

MutableFieldState useFieldState({String? initialValue}) => useGenericFieldState(initialValue: initialValue ?? "");
