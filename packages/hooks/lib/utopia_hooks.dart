import 'package:utopia_utils/utopia_utils.dart';

export 'package:flutter_hooks/flutter_hooks.dart';

export 'src/hook/compute/computed_state.dart';
export 'src/hook/compute/computed_state_value.dart';
export 'src/hook/compute/use_computed_state.dart';
export 'src/hook/effect/use_async_effect.dart';
export 'src/hook/effect/use_simple_effect.dart';
export 'src/hook/misc/use_app_lifecycle_state_callbacks.dart';
export 'src/hook/misc/use_memoized_future.dart';
export 'src/hook/misc/use_togglable_bool.dart';
export 'src/hook/misc/use_value_listenable_listener.dart';
export 'src/hook/misc/use_value_wrapper.dart';
export 'src/hook/provider/use_provided.dart';
export 'src/hook/stream/use_stream_and_log_errors.dart';
export 'src/hook/stream/use_stream_subscription.dart';
export 'src/hook/submit/submit_error.dart';
export 'src/hook/submit/submit_result.dart';
export 'src/hook/submit/submit_state.dart';
export 'src/hook/submit/use_submit_state.dart';
export 'src/widget/provider/hook_state_provider_widget.dart';
export 'src/widget/wrapper/compute/computed_list_wrapper.dart';
export 'src/widget/wrapper/compute/refreshable_computed_list_wrapper.dart';
export 'src/widget/wrapper/controller/stateless_page_controller_wrapper.dart';
export 'src/widget/wrapper/controller/stateless_tab_controller_wrapper.dart';
export 'src/widget/wrapper/controller/stateless_text_controller_wrapper.dart';

class UtopiaHooks {
  static Reporter? reporter;

  const UtopiaHooks._();
}
