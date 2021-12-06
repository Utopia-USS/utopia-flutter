import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:utopia_arch/src/validation/validator.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class FieldState implements Validatable<String> {
  final Function(String Function(BuildContext)?) onErrorChanged;
  final Function(String?) onChanged;

  final String Function() getValue;
  final String Function(BuildContext)? Function() getErrorMessage;
  final bool? Function() getIsObscured;

  ///Note: should not contain focusChange ([FieldStates] should not be coupled), there is special field in [AppTextInput] - [onSubmitFocusRequest]
  final Function(String)? onSubmit;
  final FocusNode? focusNode;
  final Function() requestFocus;
  final Function() onIsObscuredChanged;

  const FieldState({
    required this.onChanged,
    required this.getValue,
    required this.onIsObscuredChanged,
    this.focusNode,
    required this.requestFocus,
    required this.getErrorMessage,
    required this.onErrorChanged,
    required this.getIsObscured,
    required this.onSubmit,
  });

  String get value => getValue();

  String Function(BuildContext)? get errorMessage => getErrorMessage();

  bool? get isObscured => getIsObscured();

  bool get isEmpty => value.isEmpty;

  bool get isNotEmpty => value.isNotEmpty;

  bool get hasError => errorMessage != null;

  set value(String value) => onChanged(value);

  set errorMessage(String Function(BuildContext)? value) => onErrorChanged(value);
}

FieldState useFieldState({
  required String value,
  required Function(String) onChanged,
  String Function(BuildContext)? errorMessage,
  Function(String Function(BuildContext)?)? onErrorChanged,
  bool isObscurable = false,
  Function(String)? onSubmit,
}) {
  final isObscuredState = useState<bool?>(isObscurable ? true : null);
  final node = useFocusNode();
  final context = useContext();
  final valueWrapper = useValueWrapper(value);
  final errorMessageWrapper = useValueWrapper(errorMessage);

  return useMemoized(
    () => FieldState(
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
      onChanged: (value) => onChanged(value ?? ''),
    ),
  );
}

FieldState useFieldStateSimple({
  String? initialValue,
  Function(String)? onChanged,
  bool isObscurable = false,
  Function(String)? onSubmit,
  int? maxLength,
}) {
  final state = useState<String>(initialValue ?? '');
  final errorState = useState<String Function(BuildContext)?>(null);

  return useFieldState(
    value: state.value,
    onChanged: (text) {
      if (maxLength == null || text.length <= maxLength) {
        if (onChanged != null) onChanged(text);
        state.value = text;
      }
    },
    errorMessage: errorState.value,
    onErrorChanged: (text) => errorState.value = text,
    isObscurable: isObscurable,
    onSubmit: onSubmit,
  );
}
