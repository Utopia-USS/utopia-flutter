import 'submit_result.dart';
import 'submit_state.dart';

extension MutableSubmitStateExtensions<T, E> on MutableSubmitState<void, T, E> {
  Future<SubmitResult<T, E>> submit() => submitWithInput(null);
}
