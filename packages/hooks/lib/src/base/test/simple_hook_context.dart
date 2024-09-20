import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook_context_impl.dart';
import 'package:utopia_hooks/src/provider/provider_context.dart';
import 'package:utopia_hooks/src/util/immediate_locking_scheduler.dart';
import 'package:utopia_utils/utopia_utils.dart';

typedef _WaitingPredicate<R> = ({bool Function(R) predicate, Completer<void> completer});

class SimpleHookContext<R> with DiagnosticableTreeMixin, HookContextMixin implements Value<R> {
  final R Function() _build;
  late R _value;
  final Map<Type, Object?> _provided;
  final _waiting = <_WaitingPredicate<R>>[];
  bool shouldRebuild;
  var _needsBuild = false;
  final _scheduler = ImmediateLockingScheduler();

  bool get needsBuild => _needsBuild;

  SimpleHookContext(
    this._build, {
    bool init = true,
    this.shouldRebuild = true,
    Map<Type, Object?> provided = const {},
  }) : _provided = Map.of(provided) {
    if (init) _scheduler(rebuild);
  }

  @override
  R get value => _value;

  R rebuild() {
    _value = wrapBuild(_build);
    triggerPostBuildCallbacks();
    for (final entry in List.of(_waiting)) {
      if (entry.predicate(_value)) {
        _waiting.remove(entry);
        entry.completer.complete();
      }
    }
    _needsBuild = false;
    return _value;
  }

  @override
  @protected
  dynamic getUnsafe(Object key, {bool? watch}) {
    assert(watch != true, "Watching is not supported in SimpleHookContext.getUnsafe()");
    if (!_provided.containsKey(key)) return ProviderContext.valueNotFound;
    return _provided[key];
  }

  @override
  @protected
  void markNeedsBuild() {
    if (shouldRebuild) {
      _scheduler(rebuild);
    } else {
      _needsBuild = true;
    }
  }

  void setProvided<T>(T value) {
    _provided[T] = value;
    rebuild();
  }

  Future<void> waitUntil(bool Function(R) predicate) async {
    if (predicate(_value)) return;
    final completer = Completer<void>();
    _waiting.add((predicate: predicate, completer: completer));
    await completer.future;
  }

  void dispose() => disposeHooks();
}
