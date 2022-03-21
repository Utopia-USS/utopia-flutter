import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:utopia_utils/utopia_utils.dart';

T useProvided<T>() => useContext().watch<T>();

R useMappedProvided<T, R>(R Function(T) block) => useContext().select<T, R>(block);

T Function<T>() useProviderReader() => useContext().let((it) => <T>() => it.read<T>());

T useSingleProvided<T>() => useContext().read<T>();
