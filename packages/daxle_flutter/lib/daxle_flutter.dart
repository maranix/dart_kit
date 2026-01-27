/// Flutter-specific implementations for Daxle, such as [ViewModel]
/// for state management.
///
/// Example usage:
/// ```dart
/// class MyViewModel extends ViewModel {
///   int _counter = 0;
///   int get counter => _counter;
///
///   void increment() {
///     _counter++;
///     notifyListeners();
///   }
/// }
///
/// void main() async {
///   final vm = MyViewModel();
///   await vm.init();
///
///   vm.addListener(() {
///     print('Counter: ${vm.counter}');
///   });
///
///   vm.increment();
///   vm.dispose();
/// }
/// ```
library;

export 'package:daxle/daxle.dart';
export 'src/viewmodel.dart';
