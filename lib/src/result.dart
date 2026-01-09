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
  bool get isOk => this is Ok;

  /// Returns `true` if this `Result` is `Err`.
  bool get isErr => this is Err;

  /// Returns the value inside `Ok`, or evaluates and returns [orElse] if `Err`.
  T getOrElse(T Function() orElse) => switch (this) {
    Ok(:final value) => value,
    Err() => orElse(),
  };

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
  T unwrap() => switch (this) {
    Ok(:final value) => value,
    Err(:final error, :final stackTrace) => Error.throwWithStackTrace(
      error,
      stackTrace ?? StackTrace.current,
    ),
  };

  /// Maps the error inside `Err` using [f], leaves `Ok` unchanged.
  @useResult
  Result<T> mapErr(Object Function(Object) f) => switch (this) {
    Ok(:final value) => .ok(value),
    Err(:final error, :final stackTrace) => .err(f(error), stackTrace),
  };

  /// Maps the value inside `Ok` using [f], leaves `Err` unchanged.
  @useResult
  Result<R> map<R>(R Function(T) f) => switch (this) {
    Ok(:final value) => .ok(f(value)),
    Err(:final error, :final stackTrace) => .err(error, stackTrace),
  };

  /// Flat-maps the value inside `Ok` using [f], leaves `Err` unchanged.
  @useResult
  Result<R> flatMap<R>(Result<R> Function(T) f) => switch (this) {
    Ok(:final value) => f(value),
    Err(:final error, :final stackTrace) => .err(error, stackTrace),
  };

  /// Fold the `Result` into a single value.
  ///
  /// Runs [onOk] if `Ok` or [onErr] if `Err`.
  @useResult
  R fold<R>({
    required R Function(T) onOk,
    required R Function(Object error, StackTrace? stackTrace) onErr,
  }) => switch (this) {
    Ok(:final value) => onOk(value),
    Err(:final error, :final stackTrace) => onErr(error, stackTrace),
  };

  /// Returns `this` if `Ok`, otherwise evaluates and returns the result of [f] if `Err`.
  @useResult
  Result<T> orElse(Result<T> Function() f) => switch (this) {
    Ok() => this,
    Err() => f(),
  };

  /// Returns the value inside `Ok`, or throws a `ResultError` with a custom [message] if `Err`.
  T expect(String message) => switch (this) {
    Ok(:final value) => value,
    Err(:final error, :final stackTrace) => throw ResultError(
      message,
      source: error,
      stackTrace: stackTrace,
    ),
  };

  @override
  List<Object?> get props => switch (this) {
    Ok(:final value) => [value],
    Err(:final error) => [error],
  };
}

/// {@template ok}
/// Represents a successful `Result` containing a value.
/// {@endtemplate}
@immutable
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  bool get stringify => true;
}

/// {@template err}
/// Represents a failed `Result` containing an error and optional stack trace.
/// {@endtemplate}
@immutable
final class Err<T> extends Result<T> {
  const Err(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;
}

/// Extension on `Future` to convert it to a `Result`.
extension AsyncResultX<T> on Future<T> {
  /// Converts a `Future<T>` to `Future<Result<T>>`.
  Future<Result<T>> toResult() => Result.fromAsync(() => this);
}

/// {@template result_error}
/// Error thrown when `Result.expect` fails.
/// Contains the original error as [source] and optional [stackTrace].
/// {@endtemplate}
final class ResultError extends Error {
  ResultError(this.message, {this.source, this.stackTrace});

  final String message;
  final Object? source;

  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buffer = StringBuffer("ResultError: $message");

    if (source != null) buffer.writeln("\nSource: $source");
    if (stackTrace != null) buffer.writeln("\nStackTrace: $stackTrace");

    return buffer.toString();
  }
}
