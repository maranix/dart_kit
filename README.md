dart_kit
=========

**dart\_kit** is a lightweight Dart utility package that offers common abstractions and missing features to write safer, more expressive code. It includes well-known functional programming concepts like `Option`, `Result`, and `Either`, and provides utility functions to handle common programming patterns efficiently.

Features
--------

*   **Option** - A safer alternative to nullable types, representing either a value or the absence of a value.
*   **Result** - Encapsulates the result of an operation that can succeed or fail, making error handling explicit.
*   **Either** - Represents a value of one of two possible types (a success or a failure).

Installation
------------

To add `dart_kit` to your project, add the following dependency in your `pubspec.yaml` file:

```yaml 
    dependencies:
      dart_kit: ^1.0.0
```

Usage
-----

### Option

`Option` is a type that represents a value that may or may not be present. You can use it to avoid dealing with nullable types in a safer manner.

```dart
import 'package:dart_kit/dart_kit.dart';

Option someValue = Option.some(42);
Option noValue = Option.none();

print(someValue.isSome);  // true
print(noValue.isNone);    // true
``` 

### Result

`Result` encapsulates the outcome of an operation that can either succeed or fail. It has two variants: `Ok` for success, and `Err` for failure.

```dart
import 'package:dart_kit/dart_kit.dart';

Result result = Result.ok(42);
Result failure = Result.err(Exception('Something went wrong'));

print(result.isOk); // true
print(failure.isErr); // true
```

### Either

`Either` is used to represent a value that can be of one of two types, typically representing a success (Right) or failure (Left).

```dart
import 'package:dart_kit/dart_kit.dart';

Either success = Either.right(42);
Either failure = Either.left('Error occurred');

print(success.isRight);  // true
print(failure.isLeft);   // true
```

Contributing
------------

If you would like to contribute to `dart_kit`, please follow the steps below:

*   Fork this repository on GitHub.
*   Create a new branch for your changes.
*   Make your changes and commit them.
*   Submit a pull request to the main repository.

License
-------

`dart_kit` is released under the MIT License. See the [License](https://github.com/maranix/dart_kit/tree/main/LICENSE) for more information.

Contact
-------

For more information or questions, feel free to open an issue on [Issues](https://github.com/maranix/dart_kit/issues).
