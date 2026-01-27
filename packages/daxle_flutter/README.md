# daxle_flutter

A lightweight Flutter utility package built on top of `daxle`. It extends the core functional concepts of `daxle` into the Flutter ecosystem, providing specialized widgets, view models, and reactive primitives to write safer and more expressive Flutter applications.

## Features

*   **Flutter Integration**: Seamlessly integrates `Option`, `Result`, and `Either` types into Flutter widgets.
*   **ViewModel Support**: Architecture components for managing state in a functional and testable way.
*   **Safe Extensions**: Extension methods to simplify common Flutter patterns and reduce boilerplate.

## Installation

Add `daxle_flutter` to your `pubspec.yaml` file:

```yaml
dependencies:
  daxle_flutter: ^1.0.0
```

Then run `flutter pub get`.

## Usage

Import the package:

```dart
import 'package:daxle_flutter/daxle_flutter.dart';
```

### ViewModel

`ViewModel` builds upon `ChangeNotifier` to offer more capabilities and greater control over initialization and disposal. By providing strict lifecycle management and structured updates, it helps to avoid common bugs and aims to provide a more performant and maintainable architecture while remaining simple and easy to use.

```dart
class CounterViewModel extends ViewModel {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  @override
  Future<void> init() async {
    await super.init(); // Must call super
    // Perform async initialization here
  }
}

void main() async {
  final vm = CounterViewModel();
  
  // Must initialize before use
  await vm.init();

  vm.addListener(() {
    print('Count: ${vm.count}');
  });

  vm.increment();

  // Clean up
  vm.dispose();
}
```

## Contributing

This package is part of the `daxle` monorepo. Please see the root repository for general contribution guidelines.

## License

`daxle` is released under the MIT License. See the [LICENSE](LICENSE) for more information.