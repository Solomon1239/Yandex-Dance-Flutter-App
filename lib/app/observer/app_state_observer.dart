import 'dart:developer';

import 'package:yx_state/yx_state.dart';

void setupStateObserver() {
  StateManagerOverrides.observer = const AppStateObserver();
}

class AppStateObserver extends StateManagerObserver {
  const AppStateObserver();

  @override
  void onChange(
    StateManagerBase<Object?> stateManager,
    Object? currentState,
    Object? nextState,
    Object? identifier,
  ) {
    log(
      '[STATE] ${stateManager.runtimeType}: '
      '$currentState -> $nextState | id=$identifier',
    );
    super.onChange(stateManager, currentState, nextState, identifier);
  }

  @override
  void onHandleStart(
    StateManagerBase<Object?> stateManager,
    Object? identifier,
  ) {
    log('[HANDLE START] ${stateManager.runtimeType} | id=$identifier');
    super.onHandleStart(stateManager, identifier);
  }

  @override
  void onHandleDone(
    StateManagerBase<Object?> stateManager,
    Object? identifier,
  ) {
    log('[HANDLE DONE] ${stateManager.runtimeType} | id=$identifier');
    super.onHandleDone(stateManager, identifier);
  }

  @override
  void onError(
    StateManagerBase<Object?> stateManager,
    Object error,
    StackTrace stackTrace,
    Object? identifier,
  ) {
    log(
      '[ERROR] ${stateManager.runtimeType} | id=$identifier | error=$error',
      stackTrace: stackTrace,
    );
    super.onError(stateManager, error, stackTrace, identifier);
  }
}
