import 'package:utopia_arch/src/injector/injector_provider.dart';
import 'package:utopia_arch/src/service/preferences/preferences_service.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

PersistedState<T> usePreferencesPersistedState<T extends Object>(String key, {T? defaultValue}) {
  return useComplexPreferencesPersistedState<T, T>(
    key,
    toPreferences: (it) => it,
    fromPreferences: (it) => it,
    defaultValue: defaultValue,
  );
}

PersistedState<T> useEnumPreferencesPersistedState<T extends Enum>(String key, List<T> values, {T? defaultValue}) {
  return useComplexPreferencesPersistedState<T, int>(
    key,
    toPreferences: (it) => it.index,
    fromPreferences: (it) => values[it],
    defaultValue: defaultValue,
  );
}

PersistedState<T> useComplexPreferencesPersistedState<T extends Object, T2 extends Object>(
  String key, {
  required T2 Function(T) toPreferences,
  required T Function(T2) fromPreferences,
  T? defaultValue,
}) {
  assert(
    PreferencesService.supportedTypes.contains(T2),
    "Type not supported, must be one of ${PreferencesService.supportedTypes}",
  );
  final preferencesService = useInjected<PreferencesService>();
  final value = usePersistedState<T>(
    () async => (await preferencesService.load<T2>(key))?.let(fromPreferences) ?? defaultValue,
    (it) async => preferencesService.save(key, it?.let(toPreferences)),
  );
  return value;
}
