import 'dart:async';

import 'package:daxle_flutter/daxle_flutter.dart';
import 'package:test/test.dart';

class TestViewModel extends ViewModel {
  int _counter = 0;
  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();
  }
}

void main() {
  group('ViewModel', () {
    late TestViewModel viewModel;

    setUp(() {
      viewModel = TestViewModel();
    });

    test('initial state is uninitialized', () {
      expect(viewModel.state, ViewModelState.uninitialized);
    });

    test('init() transitions to initialized', () async {
      await viewModel.init();
      expect(viewModel.state, ViewModelState.initialized);
    });

    test('notifyListeners() throws when uninitialized', () {
      expect(
        () => viewModel.increment(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Cannot notify listeners on an uninitialized ViewModel'),
          ),
        ),
      );
    });

    test('init() throws if already initialized', () async {
      await viewModel.init();
      expect(
        () => viewModel.init(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('already been initialized'),
          ),
        ),
      );
    });

    test('dispose() transitions to disposed', () async {
      await viewModel.init();
      viewModel.dispose();
      expect(viewModel.state, ViewModelState.disposed);
    });

    test('dispose() throws if already disposed', () async {
      await viewModel.init();
      viewModel.dispose();
      expect(
        () => viewModel.dispose(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('already been disposed'),
          ),
        ),
      );
    });

    test('notifyListeners() throws when disposed', () async {
      await viewModel.init();
      viewModel.dispose();
      expect(
        () => viewModel.increment(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Cannot notify listeners on a disposed ViewModel'),
          ),
        ),
      );
    });

    test('init() throws if disposed', () async {
      await viewModel.init();
      viewModel.dispose();
      expect(
        () => viewModel.init(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('already been initialized or disposed'),
          ),
        ),
      );
    });

    test('bulk updates work correctly when initialized', () async {
      await viewModel.init();
      int listenerCalls = 0;
      viewModel.addListener(() => listenerCalls++);

      for (int i = 0; i < 1000; i++) {
        viewModel.increment();
      }

      expect(viewModel.counter, 1000);
      expect(listenerCalls, 1000);
    });

    test(
      'race condition: calling dispose while async operation pending',
      () async {
        // simulate an async op that tries to notify after dispose
        await viewModel.init();

        final completer = Completer<void>();

        unawaited(
          Future(() async {
            await completer.future;
            try {
              // This should ideally throw if the viewmodel is disposed check is strict,
              // but we are just incrementing.
              viewModel.increment();
            } catch (_) {
              // Expected to fail if disposed
            }
          }),
        );

        viewModel.dispose();
        completer.complete();

        // Give the future loop a chance to run
        await Future.delayed(Duration(milliseconds: 10));

        expect(viewModel.state, ViewModelState.disposed);
      },
    );

    test('rapid toggling of states', () {
      // Test rapid create-init-dispose
      for (int i = 0; i < 100; i++) {
        final vm = TestViewModel();
        vm.init();
        vm.dispose();
      }
    });
  });
}
