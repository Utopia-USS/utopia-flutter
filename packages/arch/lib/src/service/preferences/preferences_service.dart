import 'package:shared_preferences/shared_preferences.dart';


final _preferencesSetterMap = <Type, Future<void> Function(SharedPreferences, String, Object)>{
  bool: (preferences, key, value) => preferences.setBool(key, value as bool),
  int: (preferences, key, value) => preferences.setInt(key, value as int),
  double: (preferences, key, value) => preferences.setDouble(key, value as double),
  String: (preferences, key, value) => preferences.setString(key, value as String),
  List: (preferences, key, value) => preferences.setStringList(key, value as List<String>),
};

class PreferencesService {
  SharedPreferences? _preferences;

  Future<void> save(String key, Object? value) async {
    final preferences = await _ensureInitialized();
    if (value != null) {
      final preferencesSetter = _preferencesSetterMap[value.runtimeType];
      if(preferencesSetter == null) throw UnimplementedError("Invalid type for SharedPreferences");
      await preferencesSetter(preferences, key, value);
    } else {
      await preferences.remove(key);
    }
  }

  Future<T?> load<T>(String key) async {
    final preferences = await _ensureInitialized();
    return preferences.get(key) as T?;
  }

  Future<SharedPreferences> _ensureInitialized() async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }
}
