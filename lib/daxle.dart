/// `daxle` is a library that provides a set of functional programming constructs
/// inspired by languages like Rust and Haskell. It is designed to enhance the
/// robustness and clarity of Dart applications by offering explicit, type-safe
/// mechanisms for handling fallible operations and optional values.
///
/// This approach promotes safer error management and reduces the reliance on
/// traditional mechanisms such as throwing exceptions or using `null`.
///
/// This library exports three core data types:
///
/// - [Result]: For operations that can either succeed with a value or fail with an error.
/// - [Option]: For values that may or may not be present.
/// - [Either]: For values that can be one of two distinct types.
///
/// ---
///
/// ## Result&lt;T, E&gt;
///
/// The [Result] type is a union that represents a value that can be either a
/// success (`Ok`) or a failure (`Err`). It is designed for functions that can
/// fail, compelling the developer to handle both outcomes explicitly. This makes
/// error handling more robust and significantly reduces the risk of runtime crashes
/// from unhandled exceptions.
///
/// ### Use Cases for Result:
///
/// -   Functions that perform I/O operations (e.g., network requests, file system access).
/// -   Operations that involve parsing or validation.
/// -   Any function where you want to return a detailed error without throwing an exception.
///
/// ### Example:
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// Result<int, String> divide(int a, int b) {
///   if (b == 0) {
///     return Result.err('Cannot divide by zero');
///   }
///   return Result.ok(a ~/ b);
/// }
///
/// void main() {
///   final success = divide(10, 2);
///   success.fold(
///     onOk: (value) => print('Success: $value'), // Prints: Success: 5
///     onErr: (error, stackTrace) => print('Error: $error'),
///   );
///
///   final failure = divide(10, 0);
///   failure.fold(
///     onOk: (value) => print('Success: $value'),
///     onErr: (error, stackTrace) => print('Error: $error'), // Prints: Error: Cannot divide by zero
///   );
/// }
/// ```
///
/// ---
///
/// ## Option&lt;T&gt;
///
/// The [Option] type is a container for an optional value. An instance of [Option]
/// is either `Some`, containing a value, or `None`, indicating the absence of a value.
/// Its primary purpose is to provide an alternative to using `null`, offering a
/// strong encouragement at compile-time to handle the absence of a value explicitly.
///
/// ### Use Cases for Option:
///
/// -   Functions that might not return a value (e.g., finding an element in a list).
/// -   Replacing nullable types (`T?`) to enforce explicit handling of missing values.
/// -   Modeling optional parameters or fields in data structures.
///
/// ### Example:
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// Option<String> findUser(String id) {
///   if (id == '123') {
///     return Option.some('Alice');
///   }
///   return Option.none();
/// }
///
/// void main() {
///   final user = findUser('123');
///   final userName = user.getOrElse(() => 'Guest');
///   print('User: $userName'); // Prints: User: Alice
///
///   final noUser = findUser('456');
///   final defaultUser = noUser.getOrElse(() => 'Guest');
///   print('User: $defaultUser'); // Prints: User: Guest
/// }
/// ```
///
/// ---
///
/// ## Either&lt;L, R&gt;
///
/// The [Either] type is a generic sum type that can hold a value of one of two
/// distinct types: `Left` or `Right`. By convention, `Right` is used to represent
/// a success or expected value, while `Left` is used for a failure or alternative
/// value. It is similar to [Result] but more general, as it does not prescribe
/// that the `Left` type must be an error.
///
/// ### Use Cases for Either:
///
/// -   Functions that can return one of two unrelated types.
/// -   As an alternative to [Result] when the failure case is not an error but a different data flow.
/// -   Implementing functional pipelines where different types of data might diverge.
///
/// ### Example:
///
/// ```dart
/// import 'package:daxle/daxle.dart';
///
/// Either<String, int> parseNumber(String text) {
///   try {
///     return Either.right(int.parse(text));
///   } catch (e) {
///     return Either.left('Invalid number format');
///   }
/// }
///
/// void main() {
///   final result1 = parseNumber('123');
///   result1.fold(
///     (left) => print('Left: $left'),
///     (right) => print('Right: $right'), // Prints: Right: 123
///   );
///
///   final result2 = parseNumber('abc');
///   result2.fold(
///     (left) => print('Left: $left'), // Prints: Left: Invalid number format
///     (right) => print('Right: $right'),
///   );
/// }
/// ```
library;

export 'src/result.dart';
export 'src/option.dart';
export 'src/either.dart';
