import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class GenericFieldState<T> {
  final Function(String Function(BuildContext)?) onErrorChanged;
  final Function(T?) onChanged;

  final T? Function() getValue;
  final String Function(BuildContext)? Function() getErrorMessage;
  final bool? Function() getIsObscured;

  ///Note: should not contain focusChange ([GenericFieldStates] should not be coupled), there is special field in [AppTextInput] - [onSubmitFocusRequest]
  final Function(T value)? onSubmit;
  final FocusNode focusNode;
  final Function() requestFocus;
  final Function() onIsObscuredChanged;

  const GenericFieldState({
    required this.onChanged,
    required this.getValue,
    required this.onIsObscuredChanged,
    required this.focusNode,
    required this.requestFocus,
    required this.getErrorMessage,
    required this.onErrorChanged,
    required this.getIsObscured,
    required this.onSubmit,
  });

  T? get value => getValue();

  String Function(BuildContext)? get errorMessage => getErrorMessage();

  bool? get isObscured => getIsObscured();

  bool get isEmpty => value == null || value == "";

  bool get isNotEmpty => !isEmpty;

  bool get hasError => errorMessage != null;

  set value(T? value) => onChanged(value);

  set errorMessage(String Function(BuildContext)? value) => onErrorChanged(value);
}

GenericFieldState<T> useGenericFieldState<T>({
  required T? value,
  required Function(T?) onChanged,
  String Function(BuildContext)? errorMessage,
  Function(String Function(BuildContext)?)? onErrorChanged,
  bool isObscurable = false,
  Function(T)? onSubmit,
}) {
  final isObscuredState = useState<bool?>(isObscurable ? true : null);
  final node = useFocusNode();
  final context = useContext();
  final valueWrapper = useValueWrapper(value);
  final errorMessageWrapper = useValueWrapper(errorMessage);

  return useMemoized(
        () => GenericFieldState<T>(
      getValue: valueWrapper.getValue,
      getErrorMessage: errorMessageWrapper.getValue,
      getIsObscured: () => isObscuredState.value,
      focusNode: node,
      onSubmit: onSubmit,
      requestFocus: () => FocusScope.of(context).requestFocus(node),
      onErrorChanged: (text) => onErrorChanged?.call(text),
      onIsObscuredChanged: () {
        if (isObscuredState.value != null) isObscuredState.value = !isObscuredState.value!;
      },
      onChanged: (value) => onChanged(value),
    ),
  );
}
