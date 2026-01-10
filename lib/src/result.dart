import 'package:dart_kit/src/either.dart';
import 'package:dart_kit/src/option.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// {@template result}
/// Represents the result of an operation that can succeed or fail.
///
/// A `Result<T>` can be either:
/// - `Ok(value)`, representing a successful operation with a value of type [T].
/// - `Err(error, [stackTrace])`, representing a failed operation with an [error] and optional [StackTrace].
///
/// Use `Result<T>` to make success and failure explicit instead of relying on exceptions.
/// This is similar to `Result`/`Either` types in functional languages like Rust or Haskell.
///
/// Example:
/// ```dart
/// Result<int> a = .ok(10);
/// Result<int> b = .err(Exception("Failed"));
///
/// print(a.isOk); // true
/// print(b.isErr); // true
/// ```
/// {@endtemplate}
@immutable
sealed class Result<T> extends Equatable {
  /// {@macro result}
  const Result();

  /// {@template result_ok}
  /// Creates a `Result` representing a successful operation.
  ///
  /// This is equivalent to constructing an `Ok(value)`.
  ///
  /// Example:
  /// ```dart
  /// Result<int> x = .ok(5); // Ok(5)
  /// print(x.isOk); // true
  /// ```
  /// {@endtemplate}
  const factory Result.ok(T value) = Ok;

  /// {@template result_err}
  /// Creates a `Result` representing a failed operation.
  ///
  /// This is equivalent to constructing an `Err(error, [stackTrace])`.
  ///
  /// Example:
  /// ```dart
  /// Result<int> y = .err(Exception("Oops")); // Err
  /// print(y.isErr); // true
  /// ```
  /// {@endtemplate}
  const factory Result.err(Object err, [StackTrace? stackTrace]) = Err;

  /// Creates a `Result` from a synchronous function that may throw.
  ///
  /// If the function executes successfully, returns `Ok` with the value.
  /// If it throws an `Exception` or other non-`Error`, returns `Err`.
  ///
  /// **Note:** If the function throws an `Error`, it will be **re-thrown**.
  ///
  /// Example:
  /// ```dart
  /// final result = Result.from(() => 42); // Ok(42)
  /// final failure = Result.from(() => throw Exception("Oops")); // Err
  /// ```
  static Result<R> from<R>(R Function() f) {
    try {
      return .ok(f());
    } catch (err, stackTrace) {
      if (err is Error) rethrow;
      return .err(err, stackTrace);
    }
  }

  /// Creates a `Result` from an asynchronous function that may throw.
  ///
  /// If the `Future` resolves successfully, returns `Ok` with the value.
  /// If it throws an `Exception` or other non-`Error`, returns `Err`.
  ///
  /// **Note:** If the `Future` throws an `Error`, it will be **re-thrown**.
  ///
  /// Example:
  /// ```dart
  /// final result = await Result.fromAsync(() async => await fetchData()); // Ok(data)
  /// final failure = await Result.fromAsync(() async => throw Exception("Oops")); // Err
  /// ```
  static Future<Result<R>> fromAsync<R>(Future<R> Function() f) async {
    try {
      return .ok(await f());
    } catch (err, stackTrace) {
      if (err is Error) rethrow;
      return .err(err, stackTrace);
    }
  }

  /// Returns `true` if this `Result` is `Ok`.
  bool get isOk;

  /// Returns `true` if this `Result` is `Err`.
  bool get isErr;

  /// Returns the value inside `Ok`, or evaluates and returns [orElse] if `Err`.
  T getOrElse(T Function() orElse);

  /// Returns the value inside `Ok`, or throws the original error (with stack trace) if `Err`.
  ///
  /// Example:
  /// ```dart
  /// final result = .ok(5);
  /// print(result.unwrap()); // 5
  ///
  /// final failure = .err(Exception("Oops"));
  /// failure.unwrap(); // throws Exception("Oops")
  /// ```
  @useResult
  T unwrap();

  /// Maps the error inside `Err` using [f], leaves `Ok` unchanged.
  @useResult
  Result<T> mapErr(Object Function(Object) f);

  /// Maps the value inside `Ok` using [f], leaves `Err` unchanged.
  @useResult
  Result<R> map<R>(R Function(T) f);

  /// Flat-maps the value inside `Ok` using [f], leaves `Err` unchanged.
  @useResult
  Result<R> flatMap<R>(Result<R> Function(T) f);

  /// Fold the `Result` into a single value.
  ///
  /// Runs [onOk] if `Ok` or [onErr] if `Err`.
  @useResult
  R fold<R>({
    required R Function(T) onOk,
    required R Function(Object error, StackTrace? stackTrace) onErr,
  });

  /// Returns `this` if `Ok`, otherwise evaluates and returns the result of [f] if `Err`.
  @useResult
  Result<T> orElse(Result<T> Function() f);

  /// Returns the value inside `Ok`, or throws a [StateError] with [message] if `Err`.
  T expect(String message);

  /// Transforms [this] into [Option], `Ok(value)` becomes `Some(value)` and `Err` becomes `None`.
  ///
  /// Example:
  /// ```dart
  /// final result = .ok(5);
  /// print(result.unwrap()); // 5
  ///
  /// final option = result.toOption(); // Some(5)
  /// ```
  Option<T> toOption();

  /// Transforms [this] into [Either], `Ok(value)` becomes `Right(value)` and `Err` becomes `Left(error)`.
  ///
  /// Example:
  /// ```dart
  /// final result = .ok(5);
  /// print(result.unwrap()); // 5
  ///
  /// final either = result.toEither(); // Either.Right(5)
  /// ```
  Either<L, T> toEither<L>();
}

/// {@template ok}
/// Represents a successful `Result` containing a value.
/// {@endtemplate}
@immutable
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  bool get isOk => true;

  @override
  bool get isErr => false;

  @override
  T unwrap() => value;

  @override
  T expect(String message) => value;

  @override
  Result<R> flatMap<R>(Result<R> Function(T) f) => f(value);

  @override
  R fold<R>({
    required R Function(T) onOk,
    required R Function(Object error, StackTrace? stackTrace) onErr,
  }) => onOk(value);

  @override
  T getOrElse(T Function() orElse) => value;

  @override
  Result<R> map<R>(R Function(T) f) => .ok(f(value));

  @override
  Result<T> mapErr(Object Function(Object) f) => this;

  @override
  Result<T> orElse(Result<T> Function() f) => this;

  @override
  Option<T> toOption() => .some(value);

  @override
  Either<L, T> toEither<L>() => .right(value);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [value];
}

/// {@template err}
/// Represents a failed `Result` containing an error and optional stack trace.
/// {@endtemplate}
@immutable
final class Err<T> extends Result<T> {
  const Err(this.error, [this.stackTrace]);

  final Object error;

  final StackTrace? stackTrace;

  @override
  bool get isOk => false;

  @override
  bool get isErr => true;

  @override
  T unwrap() =>
      Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current);

  @override
  T expect(String message) {
    final buffer = StringBuffer("Result.err: $message");

    buffer.writeln("\nSource: ${Error.safeToString(error)}");
    if (stackTrace != null) buffer.writeln("\nStackTrace: $stackTrace");

    throw StateError(buffer.toString());
  }

  @override
  Result<R> flatMap<R>(Result<R> Function(T) f) => .err(error, stackTrace);

  @override
  R fold<R>({
    required R Function(T) onOk,
    required R Function(Object error, StackTrace? stackTrace) onErr,
  }) => onErr(error, stackTrace);

  @override
  T getOrElse(T Function() orElse) => orElse();

  @override
  Result<R> map<R>(R Function(T) f) => .err(error, stackTrace);

  @override
  Result<T> mapErr(Object Function(Object) f) => .err(f(error), stackTrace);

  @override
  Result<T> orElse(Result<T> Function() f) => f();

  @override
  Option<T> toOption() => .none();

  @override
  Either<L, T> toEither<L>() => .left(error as L);

  @override
  List<Object> get props => [error];
}

/// Extension on `Future` to convert it to a `Result`.
extension AsyncResultX<T> on Future<T> {
  /// Converts a `Future<T>` to `Future<Result<T>>`.
  Future<Result<T>> toResult() => Result.fromAsync(() => this);
}
