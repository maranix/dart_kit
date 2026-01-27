import 'package:daxle_flutter/daxle_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;

// Define a simple ViewModel
class CounterViewModel extends ViewModel {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  @override
  Future<void> init() async {
    await super.init();
    debugPrint('CounterViewModel initialized');
  }

  @override
  void dispose() {
    debugPrint('CounterViewModel disposing');
    super.dispose();
  }
}

void main() async {
  // 1. Create instance
  final viewModel = CounterViewModel();
  debugPrint(
    'State before init: ${viewModel.state}',
  ); // ViewModelState.uninitialized

  // 2. Initialize
  await viewModel.init();
  debugPrint(
    'State after init: ${viewModel.state}',
  ); // ViewModelState.initialized

  // 3. Listen to changes
  viewModel.addListener(() {
    debugPrint('Counter updated: ${viewModel.count}');
  });

  // 4. Update state
  viewModel.increment(); // debugPrints: Counter updated: 1
  viewModel.increment(); // debugPrints: Counter updated: 2

  // 5. Dispose
  viewModel.dispose();
  debugPrint(
    'State after dispose: ${viewModel.state}',
  ); // ViewModelState.disposed

  // 6. Verify strict lifecycle (Demonstration of safety)
  try {
    viewModel.increment();
  } catch (e) {
    debugPrint('Caught expected error: $e');
  }
}
