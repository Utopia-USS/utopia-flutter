import 'package:utopia_hooks/hook/submit/submit_result.dart';
import 'package:utopia_hooks/hook/submit/submit_state.dart';

extension MutableSubmitStateExtensions<T, E> on MutableSubmitState<void, T, E> {
  Future<SubmitResult<T, E>> submit() => submitWithInput(null);
}