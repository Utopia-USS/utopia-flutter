import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

T useProvided<T>() => useContext().watch<T>();
T useSingleProvided<T>() => useContext().read<T>();
