import 'package:utopia_arch/src/injector/injector_provider.dart';
import 'package:utopia_arch/src/service/preferences/preferences_service.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

PersistedState<T> usePreferencesPersistedState<T extends Object>(String key) =>
    useComplexPreferencesPersistedState<T, T>(key, toPreferences: (it) => it, fromPreferences: (it) => it);

PersistedState<T> useComplexPreferencesPersistedState<T extends Object, T2 extends Object>(
  String key, {
  required T2 Function(T) toPreferences,
  required T Function(T2) fromPreferences,
}) {
  assert(
    PreferencesService.supportedTypes.contains(T2),
    "Type not supported, must be one of ${PreferencesService.supportedTypes}",
  );
  final preferencesService = useInjected<PreferencesService>();
  final value = usePersistedState<T>(
    () async => (await preferencesService.load<T2>(key))?.let(fromPreferences),
    (it) async => preferencesService.save(key, it?.let(toPreferences)),
  );
  return value;
}
