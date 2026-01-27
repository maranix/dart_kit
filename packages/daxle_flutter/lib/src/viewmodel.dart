import 'dart:async';

import 'package:flutter/foundation.dart';

/// Represents the current lifecycle state of a [ViewModel].
enum ViewModelState {
  /// The [ViewModel] has been instantiated but has not yet finished initialization.
  uninitialized,

  /// The [ViewModel] has completed its initialization process and is ready for use.
  initialized,

  /// The [ViewModel] has been disposed and should no longer be accessed.
  disposed,
}

/// A base class for ViewModels that manages lifecycle states and provides
/// safe access to [notifyListeners].
///
/// Subclasses must call [init] to start using the ViewModel and must call
/// [dispose] when it is no longer needed.
///
/// Attempting to use the ViewModel before [init] or after [dispose] in an invalid
/// way will result in errors, ensuring strict lifecycle management.
abstract class ViewModel extends ChangeNotifier {
  /// Creates a [ViewModel] in the [ViewModelState.uninitialized] state.
  ViewModel();

  ViewModelState _state = ViewModelState.uninitialized;

  /// The current state of the [ViewModel].
  ViewModelState get state => _state;

  /// Initializes the [ViewModel].
  ///
  /// This method must be called exactly once before using the ViewModel.
  /// Subclasses can override this to perform asynchronous initialization,
  /// but must call `super.init()` at the beginning.
  ///
  /// Throws a [StateError] if the ViewModel has already been initialized
  /// or if it has been disposed.
  @mustCallSuper
  FutureOr<void> init() {
    if (_state != .uninitialized) {
      throw StateError(
        'ViewModel has already been initialized or disposed. '
        'Current state: $_state',
      );
    }
    _setState(.initialized);
  }

  /// Disposes the [ViewModel].
  ///
  /// This method must be called exactly once when the ViewModel is no longer needed.
  /// Subclasses can override this to perform cleanup, but must call `super.dispose()`
  /// at the end.
  ///
  /// Throws a [StateError] if the ViewModel has already been disposed.
  @override
  @mustCallSuper
  void dispose() {
    if (_state == .disposed) {
      throw StateError('ViewModel has already been disposed.');
    }
    _setState(.disposed);
    super.dispose();
  }

  /// Notifies listeners that the ViewModel has changed.
  ///
  /// This method can only be called when the ViewModel is in the
  /// [ViewModelState.initialized] state.
  ///
  /// Throws a [StateError] if called when uninitialized or disposed.
  @override
  void notifyListeners() => switch (_state) {
    .uninitialized => throw StateError(
      'Cannot notify listeners on an uninitialized ViewModel. '
      'Ensure init() is called before modifying state.',
    ),
    .disposed => throw StateError(
      'Cannot notify listeners on a disposed ViewModel.',
    ),
    .initialized => super.notifyListeners(),
  };

  /// Updates the internal state and notifies listeners.
  ///
  /// Used internally to transition between lifecycle states.
  void _setState(ViewModelState state) {
    _state = state;
    // We call super.notifyListeners() directly here because we might be
    // transitioning TO initialized (so public notifyListeners would work)
    // or TO disposed (where public notifyListeners would throw).
    // State changes are always notification-worthy events regardless of the
    // resulting state, providing the listeners haven't been removed yet
    // (which they shouldn't be for the transition to disposed).
    super.notifyListeners();
  }
}
