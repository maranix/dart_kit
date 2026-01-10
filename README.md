# dart_kit

`dart_kit` is a library that provides a set of functional programming constructs inspired by languages like Rust and Haskell. It is designed to enhance the robustness and clarity of Dart applications by offering explicit, type-safe mechanisms for handling fallible operations and optional values.

This approach promotes safer error management and reduces the reliance on traditional mechanisms such as throwing exceptions or using `null`.

## Core Concepts

The library provides three core data types to handle common programming scenarios in a more predictable and functional way.

*   **Option<T>**: A container for an optional value. An instance of `Option` is either `Some`, containing a value, or `None`, indicating the absence of a value. It provides a strong encouragement at compile-time to handle the absence of a value explicitly, offering an alternative to using `null`.

*   **Result<T>**: A type that represents the outcome of an operation that can either succeed (`Ok`) or fail (`Err`). It is designed for functions that can fail, compelling the developer to handle both outcomes explicitly. This makes error handling more robust and significantly reduces the risk of runtime crashes from unhandled exceptions.

*   **Either<L, R>**: A generic type that can hold a value of one of two distinct types: `Left` or `Right`. By convention, `Right` is used to represent a success or expected value, while `Left` is used for a failure or alternative value. It is similar to `Result` but more general.

## Installation

To add `dart_kit` to your project, add the following dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  dart_kit: ^1.0.0
```

Then, run `dart pub get` or `flutter pub get`.

## Usage

Import the library to start using the functional types.

```dart
import 'package:dart_kit/dart_kit.dart';
```

### Option

Use `Option` to handle values that might be absent without resorting to `null`.

```dart
void main() {
  final config = {'host': '127.0.0.1', 'port': '8080'};

  // Tries to find 'port' in the config map.
  Option<String> portOption = config.containsKey('port')
      ? Option.some(config['port']!)
      : Option.none();

  // Use flatMap to handle a potential parsing failure.
  Option<int> portNumber = portOption.flatMap((p) =>
    Option.from(() => int.parse(p))
  );

  // Use getOrElse to provide a default value.
  int finalPort = portNumber.getOrElse(() => 80);

  print('Port: $finalPort'); // Prints: Port: 8080

  // ---

  // Tries to find 'user', which is absent.
  Option<String> userOption = config.containsKey('user')
      ? Option.some(config['user']!)
      : Option.none();

  print('User: ${userOption.getOrElse(() => 'guest')}'); // Prints: User: guest
}
```

### Result

Use `Result` to handle functions that can succeed or fail, making error handling explicit.

```dart
void main() {
  Result<int, String> divide(int a, int b) {
    if (b == 0) {
      return Result.err('Cannot divide by zero');
    } else {
      return Result.ok(a ~/ b);
    }
  }

  Result<int, String> success = divide(10, 2);

  // Map over a successful result
  final squared = success.map((value) => value * value);
  print('Squared value: ${squared.unwrap()}'); // Prints: Squared value: 25

  Result<int, String> failure = divide(10, 0);

  // Handle both success and failure cases using fold
  String message = failure.fold(
    onOk: (value) => 'Result is $value',
    onErr: (error, _) => 'Error: $error',
  );

  print(message); // Prints: Error: Cannot divide by zero
}
```

### Either

Use `Either` to represent a value that can be one of two distinct types.

```dart
void main() {
  // A function that returns one of two types
  Either<String, int> parseInput(String input) {
    return int.tryParse(input) != null
        ? Either.right(int.parse(input))
        : Either.left('Input is not a number');
  }

  Either<String, int> numericInput = parseInput('123');
  Either<String, int> textInput = parseInput('abc');

  // Handle the 'Right' case
  numericInput.fold(
    (error) => print('This is not called.'),
    (number) => print('Parsed number: $number'), // Prints: Parsed number: 123
  );

  // Handle the 'Left' case
  textInput.fold(
    (error) => print(error), // Prints: Input is not a number
    (number) => print('This is not called.'),
  );
}
```

## Contributing

If you would like to contribute to `dart_kit`, please follow the steps below:

*   Fork this repository on GitHub.
*   Create a new branch for your changes.
*   Make your changes and commit them.
*   Submit a pull request to the main repository.

## License

`dart_kit` is released under the MIT License. See the [LICENSE](LICENSE) for more information.

