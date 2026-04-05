import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:yandex_dance/core/ui/widgets/snackbar/app_snackbar.dart';

/// Shows error/success snackbars from a state manager's stream while
/// de-duplicating consecutive identical messages.
///
/// Usage:
/// ```dart
/// class _MyPageState extends State<MyPage>
///     with StateManagerListenerMixin<MyPage, MyState> {
///   late final MyManager _manager;
///
///   @override
///   Stream<MyState> get stateStream => _manager.stream;
///
///   @override
///   String? errorMessageOf(MyState state) => state.errorMessage;
///
///   @override
///   void initState() {
///     super.initState();
///     _manager = sl<MyManager>();
///     attachStateListener();
///   }
///
///   @override
///   void dispose() {
///     _manager.close();
///     super.dispose();
///   }
/// }
/// ```
mixin StateManagerListenerMixin<W extends StatefulWidget, S> on State<W> {
  StreamSubscription<S>? _stateSubscription;
  String? _lastError;
  String? _lastSuccess;

  /// The stream of states to observe.
  Stream<S> get stateStream;

  /// Extract the current error message from [state], or `null` for none.
  String? errorMessageOf(S state);

  /// Extract the current success message from [state], or `null` for none.
  /// Defaults to `null` — override to enable success snackbars.
  String? successMessageOf(S state) => null;

  /// Hook for custom side effects on each state change. Called after
  /// snackbars are shown.
  void onStateChange(S state) {}

  /// Call from [initState] after the manager is ready.
  void attachStateListener() {
    _stateSubscription = stateStream.listen((state) {
      if (!mounted) return;

      final error = errorMessageOf(state);
      if (error != null && error.isNotEmpty && error != _lastError) {
        _lastError = error;
        AppSnackBar.showError(context, error);
      }

      final success = successMessageOf(state);
      if (success != null && success.isNotEmpty && success != _lastSuccess) {
        _lastSuccess = success;
        AppSnackBar.showSuccess(context, success);
      }

      onStateChange(state);
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }
}
