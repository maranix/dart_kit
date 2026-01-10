import 'package:daxle/src/either.dart';
import 'package:daxle/src/result.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' show immutable, useResult;

/// {@template option}
/// Represents an optional value of type [T].
///
/// An `Option<T>` can be either:
/// - `Some(value)`, representing the presence of a value.
/// - `None()`, representing the absence of a value.
///
/// Use `Option<T>` to avoid nullable types and make the presence or absence of a value explicit.
/// This is similar to `Option`/`Maybe` in functional languages like Rust or Haskell.
///
/// Example:
/// ```dart
/// Option<int> a = .some(10);
/// Option<int> b = .none();
///
/// print(a.isSome); // true
/// print(b.isNone); // true
/// ```
/// {@endtemplate}
@immutable
sealed class Option<T> extends Equatable {
  /// {@macro option}
  const Option();

  /// {@template option_some}
  /// Creates an `Option` containing a value of type [T].
  ///
  /// This is equivalent to constructing a `Some(value)`.
  ///
  /// Example:
  /// ```dart
  /// Option<int> x = .some(5); // Some(5)
  /// print(x.isSome); // true
  /// ```
  /// {@endtemplate}
  const factory Option.some(T value) = Some;

  /// {@template option_none}
  /// Creates an `Option` without a value.
  ///
  /// This is equivalent to constructing a `None()`.
  ///
  /// Example:
  /// ```dart
  /// Option<int> y = .none(); // None
  /// print(y.isNone); // true
  /// ```
  /// {@endtemplate}
  const factory Option.none() = None;

  /// Creates a new `Option` from a synchronous function that may throw an error.
  ///
  /// If the function executes successfully, a `Some` containing the result is returned.
  /// If the function throws an error (or an exception), a `None` is returned.
  ///
  /// This method is useful when you want to wrap a potentially failing or null-returning function in an `Option` and avoid dealing with `null` or exceptions directly.
  ///
  /// **Note:** If the function throws an `Error` (as opposed to an `Exception`), it will be **re-thrown**.
  ///
  /// This is because `Error` in Dart is typically used for conditions that represent **bugs or critical issues** in the program, rather than recoverable runtime failures (like IO or network errors).
  /// Therefore, `Error` is rethrown, so that it can be properly handled elsewhere, rather than being suppressed or returned as part of normal error handling.
  ///
  /// Example:
  /// ```dart
  /// final option = Option.from(() => 42); // returns Some(42)
  /// print(option); // Some(42)
  ///
  /// final noneOption = Option.from(() => throw Exception("Oops")); // returns None
  /// print(noneOption); // None
  /// ```
  static Option<R> from<R extends Object>(R Function() f) {
    try {
      return .some(f());
    } catch (err) {
      if (err is Error) rethrow;
      return .none();
    }
  }

  /// Creates a new `Option` from an asynchronous function that may throw an error.
  ///
  /// If the asynchronous function resolves successfully, a `Some` containing the result is returned.
  /// If the function throws an error (or exception), a `None` is returned.
  ///
  /// This method is useful for handling asynchronous operations that may either succeed with a value or fail,
  /// without needing to deal with `null` or uncaught exceptions directly.
  ///
  /// Note: Unlike synchronous `Option.from`, this method must be awaited as it handles `Future` values.
  ///
  /// If the asynchronous function throws an `Error` (as opposed to an `Exception`), it will be **re-thrown**.
  ///
  /// This is because `Error` in Dart is typically used for conditions that represent **bugs or critical issues** in the program, rather than recoverable runtime failures (like IO or network errors).
  /// Therefore, `Error` is rethrown, so that it can be properly handled elsewhere, rather than being suppressed or returned as part of normal error handling.
  ///
  /// Example:
  /// ```dart
  /// final option = await Option.fromAsync(() async => await fetchData()); // returns Some(data)
  /// print(option); // Some(data)
  ///
  /// final noneOption = await Option.fromAsync(() async => throw Exception("Error")); // returns None
  /// print(noneOption); // None
  /// ```
  static Future<Option<R>> fromAsync<R extends Object>(
    Future<R> Function() f,
  ) async {
    try {
      return .some(await f());
    } catch (err) {
      if (err is Error) rethrow;
      return .none();
    }
  }

  /// Returns `true` if this `Option` contains a value (`Some`), `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final x = .some(42);
  /// print(x.isSome); // true
  ///
  /// final y = .none<int>();
  /// print(y.isSome); // false
  /// ```
  bool get isSome;

  /// Returns `true` if this `Option` does not contain a value (`None`), `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final x = .none<int>();
  /// print(x.isNone); // true
  ///
  /// final y = .some(42);
  /// print(y.isNone); // false
  /// ```
  bool get isNone;

  /// Returns the value inside `Some`, or evaluates and returns the result of [orElse] if `None`.
  ///
  /// Example:
  /// ```dart
  /// Option<int> a = Some(5);
  /// Option<int> b = None();
  /// a.getOrElse(() => 0); // returns 5
  /// b.getOrElse(() => 0); // returns 0
  /// ```
  T getOrElse(T Function() orElse);

  /// Returns the value inside `Some`.
  ///
  /// Throws [StateError] if the Option is `None`.
  ///
  /// Use only when you are certain the Option contains a value.
  T unwrap();

  /// Returns the value inside `Some`.
  ///
  /// Throws [StateError] with [message] if the Option is `None`.
  ///
  /// Use only when you are certain the Option contains a value.
  T expect(String message);

  /// Transforms the value inside `Some` using [f] and returns a new Option.
  ///
  /// - If `this` is `Some`, applies `f` to the contained value and returns `Some(f(value))`.
  /// - If `this` is `None`, returns `None<R>`.
  ///
  /// Example:
  /// ```dart
  /// Option<int> x = .some(2);
  /// Option<String> y = x.map((v) => 'Value: $v'); // Some('Value: 2')
  /// Option<int> z = .none<int>();
  /// Option<String> w = z.map((v) => 'Value: $v'); // None<String>
  /// ```
  @useResult
  Option<R> map<R extends Object>(R Function(T) f);

  /// Applies [f] to the value inside `Some`, returning the resulting Option.
  ///
  /// - If `this` is `Some(value)`, returns `f(value)`.
  /// - If `this` is `None`, returns `None<R>`.
  ///
  /// Example:
  /// ```dart
  /// Option<String> parse(String s) => s.isNotEmpty ? .some(s) : .none();
  /// Option<String> result = .some('hello').flatMap(parse); // Some('hello')
  /// Option<String> result2 = .none<String>().flatMap(parse); // None<String>
  /// ```
  @useResult
  Option<R> flatMap<R extends Object>(Option<R> Function(T) f);

  /// Reduces the Option to a single value of type [R].
  ///
  /// - If `this` is `Some(value)`, returns `onSome(value)`.
  /// - If `this` is `None`, returns `onNone()`.
  ///
  /// Example:
  /// ```dart
  /// Option<int> x = .some(5);
  /// int doubled = x.fold(onSome: (v) => v * 2, onNone: () => 0); // 10
  /// Option<int> y = .none<int>();
  /// int defaultVal = y.fold(onSome: (v) => v * 2, onNone: () => 0); // 0
  /// ```
  @useResult
  R fold<R extends Object>({
    required R Function(T) onSome,
    required R Function() onNone,
  });

  /// Returns `Some(value)` if the value satisfies [predicate], otherwise returns `None`.
  ///
  /// - If `this` is `Some(value)` and `predicate(value)` returns `true`, returns `this`.
  /// - If `this` is `Some(value)` and `predicate(value)` returns `false`, returns `None`.
  /// - If `this` is `None`, returns `None`.
  ///
  /// Example:
  /// ```dart
  /// Option<int> x = .some(5);
  /// x.filter((v) => v > 3); // Some(5)
  /// x.filter((v) => v > 10); // None
  /// Option<int> y = .none<int>();
  /// y.filter((v) => v > 3); // None
  /// ```
  @useResult
  Option<T> filter(bool Function(T) predicate);

  /// Returns `this` if `Some`, otherwise evaluates and returns the result of [f] if `None`.
  @useResult
  Option<T> orElse(Option<T> Function() f);

  /// Executes [f] on the value inside `Some`, if present, and returns the original `Option`.
  ///
  /// - If `this` is `Some(value)`, calls `f(value)` and returns `this`.
  /// - If `this` is `None`, does nothing and returns `this`.
  ///
  /// Useful for side-effects like logging, debugging, or chaining operations.
  ///
  /// Example:
  /// ```dart
  /// Option<int> x = .some(42);
  /// x.inspect((v) => print('Value is $v')); // prints: Value is 42
  /// Option<int> y = .none<int>();
  /// y.inspect((v) => print('Will not print')); // does nothing
  /// ```
  Option<T> inspect(void Function(T value) f);

  /// Returns `true` if `Option` contains [val].
  ///
  /// Example:
  /// ```dart
  /// Option<int> x = .some(42);
  /// x.contains(42); // true
  /// ```
  bool contains(T val);

  /// Transforms [this] into [Result<T, E>] with `Some(value)` as `Ok` and [err] as `Err` if `None`.
  ///
  /// Example:
  /// ```dart
  /// Option<int> x = .some(42);
  /// final result = x.toResult(() => "error"); // Result.Ok(42)
  /// ```
  Result<T, E> toResult<E>(E Function() err);

  /// Transforms [this] into [Either<L, T>] with `Some(value)` as `Right` and [left] as `Left` if `None`.
  ///
  /// Example:
  /// ```dart
  /// Option<int> x = .some(42);
  /// final result = x.toEither(() => Exception()); // Either.Right(42)
  /// ```
  ///
  /// If no `left` is provided, it throws an error when this is `None`.
  Either<L, T> toEither<L>([L Function()? left]);
}

/// {@template some_class}
/// Represents an `Option` containing a value of type [T].
///
/// Typically constructed via `Option.some(value)`.
///
/// Example:
/// ```dart
/// final someValue = Some(42);
/// print(someValue.isSome); // true
/// print(someValue.unwrap()); // 42
/// ```
/// {@endtemplate}
@immutable
final class Some<T> extends Option<T> {
  /// {@macro some_class}
  const Some(this.value);

  /// The value contained in this `Some`.
  final T value;

  @override
  bool get isSome => true;

  @override
  bool get isNone => false;

  @override
  bool contains(T val) => val == value;

  @override
  T unwrap() => value;

  @override
  T expect(String message) => value;

  @override
  Option<T> filter(bool Function(T) predicate) {
    if (predicate(value)) return this;
    return .none();
  }

  @override
  Option<R> flatMap<R extends Object>(Option<R> Function(T) f) => f(value);

  @override
  R fold<R extends Object>({
    required R Function(T) onSome,
    required R Function() onNone,
  }) => onSome(value);

  @override
  T getOrElse(T Function() orElse) => value;

  @override
  Option<T> inspect(void Function(T) f) {
    f(value);
    return this;
  }

  @override
  Option<R> map<R extends Object>(R Function(T) f) => .some(f(value));

  @override
  Option<T> orElse(Option<T> Function() f) => this;

  @override
  Result<T, E> toResult<E>(E Function() err) => Ok(value);

  @override
  Either<L, T> toEither<L>([L Function()? left]) => .right(value);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [value];
}

/// {@template none_class}
/// Represents an `Option` with no value.
///
/// Typically constructed via `Option.none()`.
///
/// Example:
/// ```dart
/// final noneValue = None<int>();
/// print(noneValue.isNone); // true
/// ```
/// {@endtemplate}
@immutable
final class None<T> extends Option<T> {
  /// {@macro none_class}
  const None();

  @override
  bool get isSome => false;

  @override
  bool get isNone => true;

  @override
  bool contains(T val) => false;

  @override
  T unwrap() => throw StateError("Attempted to unwrap `None`");

  @override
  T expect(String message) => throw StateError(message);

  @override
  Option<T> filter(bool Function(T) predicate) => .none();

  @override
  Option<R> flatMap<R extends Object>(Option<R> Function(T) f) => .none();

  @override
  R fold<R extends Object>({
    required R Function(T) onSome,
    required R Function() onNone,
  }) => onNone();

  @override
  T getOrElse(T Function() orElse) => orElse();

  @override
  Option<T> inspect(void Function(T value) f) => .none();

  @override
  Option<R> map<R extends Object>(R Function(T) f) => .none();

  @override
  Option<T> orElse(Option<T> Function() f) => f();

  @override
  Result<T, E> toResult<E>(E Function() err) => Err(err());

  @override
  Either<L, T> toEither<L>([L Function()? left]) {
    if (left == null) {
      throw StateError(
        "Cannot convert None to Either without a left callback.",
      );
    }

    return Either.left(left());
  }

  @override
  bool operator ==(Object other) => other is None; // ignore generics

  @override
  int get hashCode => 0;

  @override
  List<Object?> get props => const [];
}
