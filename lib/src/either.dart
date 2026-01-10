import 'package:equatable/equatable.dart';
import 'package:dart_kit/src/result.dart';

/// {@template either}
/// Represents a value of one of two possible types: [L] (Left) or [R] (Right).
///
/// An `Either<L, R>` can be either:
/// - `Left(value)`, representing one possible value.
/// - `Right(value)`, representing the other possible value.
///
/// Unlike `Result`, `Either` does **not** imply success or failure semantics.
/// It is a general-purpose sum type that can be used whenever a value may be
/// one of two different types.
///
/// This is similar to `Either` in functional languages like Haskell, Scala,
/// and Rust.
///
/// Example:
/// ```dart
/// Either<String, int> a = .right(10);
/// Either<String, int> b = .left("error");
///
/// print(a.isRight); // true
/// print(b.isLeft);  // true
/// ```
/// {@endtemplate}
sealed class Either<L, R> extends Equatable {
  /// {@macro either}
  const Either();

  /// {@template either_left}
  /// Creates an `Either` containing a value of type [L].
  ///
  /// This is equivalent to constructing a `Left(value)`.
  ///
  /// Example:
  /// ```dart
  /// Either<String, int> x = .left("failure");
  /// print(x.isLeft); // true
  /// ```
  /// {@endtemplate}
  const factory Either.left(L value) = Left<L, R>;

  /// {@template either_right}
  /// Creates an `Either` containing a value of type [R].
  ///
  /// This is equivalent to constructing a `Right(value)`.
  ///
  /// Example:
  /// ```dart
  /// Either<String, int> y = .right(42);
  /// print(y.isRight); // true
  /// ```
  /// {@endtemplate}
  const factory Either.right(R value) = Right<L, R>;

  /// Returns `true` if this `Either` is a `Left`, `false` otherwise.
  bool get isLeft;

  /// Returns `true` if this `Either` is a `Right`, `false` otherwise.
  bool get isRight;

  /// Returns `Left` value if exists.
  L? get leftOrNull;

  /// Returns `Right` value if exists.
  R? get rightOrNull;

  /// Returns the value inside `Right`.
  ///
  /// Throws a [StateError] if this `Either` is `Left`.
  ///
  /// Use only when you are certain the value is a `Right`.
  R unwrap();

  /// Returns the value inside `Left`.
  ///
  /// Throws a [StateError] if this `Either` is `Right`.
  ///
  /// Use only when you are certain the value is a `Left`.
  L unwrapLeft();

  /// Applies [f] to the value inside `Right`, if present.
  ///
  /// If this is a `Left`, it is returned unchanged.
  ///
  /// Example:
  /// ```dart
  /// final e = Either<String, int>.right(2);
  /// final result = e.map((x) => x * 2); // Right(4)
  /// ```
  Either<L, T> map<T>(T Function(R) f);

  /// Applies [f] to the value inside `Left`, if present.
  ///
  /// If this is a `Right`, it is returned unchanged.
  Either<T, R> mapLeft<T>(T Function(L) f);

  /// Chains computations on the `Right` value.
  ///
  /// If this is a `Left`, it is returned unchanged.
  Either<L, T> flatMap<T>(Either<L, T> Function(R) f);

  /// Chains computations on the `Left` value.
  ///
  /// If this is a `Right`, it is returned unchanged.
  Either<T, R> flatMapLeft<T>(Either<T, R> Function(L) f);

  /// Folds this `Either` into a single value.
  ///
  /// Executes [onLeft] if this is `Left`,
  /// or [onRight] if this is `Right`.
  ///
  /// Example:
  /// ```dart
  /// final e = Either<String, int>.right(10);
  /// final result = e.fold(
  ///   (l) => "Left: $l",
  ///   (r) => "Right: $r",
  /// );
  /// ```
  T fold<T>(T Function(L) onLeft, T Function(R) onRight);

  /// Returns the value inside `Right`, or evaluates and returns [orElse] if `Left`.
  ///
  /// Example:
  /// ```dart
  /// final e = Either<String, int>.left("oops");
  /// e.getOrElse(() => 0); // returns 0
  /// ```
  R getOrElse(R Function() orElse);

  /// Returns the value inside `Left`, or evaluates and returns [orElse] if `Right`.
  ///
  /// Example:
  /// ```dart
  /// final e = Either<String, int>.left("oops");
  /// e.getOrElse(() => 0); // returns "oops"
  /// ```
  L getOrElseLeft(L Function() orElse);

  /// Returns `Right`, or evaluates and returns [orElse] if `Left`.
  ///
  /// Example:
  /// ```dart
  /// final e = Either<String, int>.left("oops");
  /// e.orElse(() => .right(20)); // returns Right(20)
  /// ```
  Right<L, R> orElse(Right<L, R> Function() orElse);

  /// Returns `Left`, or evaluates and returns [orElse] if `Left`.
  ///
  /// Example:
  /// ```dart
  /// final e = Either<String, int>.left("oops");
  /// e.orElseLeft(() => .left("bang")); // returns Left("bang")
  /// ```
  Left<L, R> orElseLeft(Left<L, R> Function() orElse);

  /// Returns `true` if this is a `Right` and contains [value].
  bool contains(R value);

  /// Returns `true` if this is a `Left` and contains [value].
  bool containsLeft(L value);

  /// Executes [f] for side effects if this is `Right`.
  ///
  /// Returns this `Either` unchanged.
  Either<L, R> inspect(void Function(R) f);

  /// Executes [f] for side effects if this is `Left`.
  ///
  /// Returns this `Either` unchanged.
  Either<L, R> inspectLeft(void Function(L) f);

  /// Swaps the sides of this `Either`.
  ///
  /// `Left<L, R>` becomes `Right<R, L>` and vice versa.
  ///
  /// Example:
  /// ```dart
  /// final e = Either<String, int>.left("err");
  /// final swapped = e.swap(); // Right("err")
  /// ```
  Either<R, L> swap();

  /// Converts this `Either` into a `Result`.
  ///
  /// The `Right` value is mapped to `Ok`.
  /// The `Left` value is mapped to `Err` using [mapErr].
  ///
  /// This method is useful when an `Either` is used as a general-purpose
  /// sum type, but needs to be converted into a `Result` with explicit
  /// success and failure semantics.
  ///
  /// Example:
  /// ```dart
  /// final either = Either<String, int>.left("not a number");
  ///
  /// final result = either.toResult(
  ///   (err) => FormatException(err),
  /// );
  ///
  /// // result is Err(FormatException("not a number"))
  /// ```
  ///
  /// If this is a `Right`, [mapErr] is not evaluated.
  ///
  /// See also:
  /// - [Either], for a general-purpose two-value sum type
  /// - [Result], for success/failure semantics
  Result<R> toResult(Object Function(L) mapErr);

  @override
  bool get stringify => true;
}

/// {@template either_left_class}
/// Represents the `Left` variant of an `Either<L, R>`.
///
/// A `Left` contains a value of type [L].
///
/// `Left` does **not** imply an error or failure by itself.
/// It simply represents one side of the `Either` sum type.
/// Any semantic meaning (such as failure, alternate path, or special case)
/// is entirely determined by how the type is used.
///
/// Example:
/// ```dart
/// final value = Either<String, int>.left("not a number");
///
/// print(value.isLeft);  // true
/// print(value.isRight); // false
/// ```
/// {@endtemplate}
final class Left<L, R> extends Either<L, R> {
  /// {@macro either_left_class}
  final L value;

  /// Creates a `Left` containing [value].
  const Left(this.value);

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;

  @override
  L? get leftOrNull => value;

  @override
  R? get rightOrNull => null;

  @override
  bool contains(R value) => false;

  @override
  bool containsLeft(L value) => this.value == value;

  @override
  R unwrap() => throw StateError("Attempted to unwrap `Right` from `Left`");

  @override
  L unwrapLeft() => value;

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R) f) => .left(value);

  @override
  Either<T, R> flatMapLeft<T>(Either<T, R> Function(L) f) => f(value);

  @override
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) => onLeft(value);

  @override
  R getOrElse(R Function() orElse) => orElse();

  @override
  L getOrElseLeft(L Function() orElse) => value;

  @override
  Either<L, R> inspect(void Function(R) f) => this;

  @override
  Either<L, R> inspectLeft(void Function(L) f) {
    f(value);
    return this;
  }

  @override
  Either<L, T> map<T>(T Function(R) f) => .left(value);

  @override
  Either<T, R> mapLeft<T>(T Function(L) f) => .left(f(value));

  @override
  Either<R, L> swap() => .right(value);

  @override
  Result<R> toResult(Object Function(L) mapErr) => .err(mapErr(value));

  @override
  Right<L, R> orElse(Right<L, R> Function() orElse) => orElse();

  @override
  Left<L, R> orElseLeft(Left<L, R> Function() orElse) => this;

  @override
  List<Object?> get props => [value];
}

/// {@template either_right_class}
/// Represents the `Right` variant of an `Either<L, R>`.
///
/// A `Right` contains a value of type [R].
///
/// `Right` does **not** imply success by itself.
/// It simply represents one side of the `Either` sum type.
/// Any semantic meaning (such as success, primary path, or preferred value)
/// is entirely determined by how the type is used.
///
/// Example:
/// ```dart
/// final value = Either<String, int>.right(42);
///
/// print(value.isRight); // true
/// print(value.isLeft);  // false
/// ```
/// {@endtemplate}
final class Right<L, R> extends Either<L, R> {
  /// {@macro either_right_class}
  final R value;

  /// Creates a `Right` containing [value].
  const Right(this.value);

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;

  @override
  L? get leftOrNull => null;

  @override
  R? get rightOrNull => value;

  @override
  bool contains(R value) => this.value == value;

  @override
  bool containsLeft(L value) => false;

  @override
  R unwrap() => value;

  @override
  L unwrapLeft() => throw StateError("Attempted to unwrap `Left` from `Right`");

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R) f) => f(value);

  @override
  Either<T, R> flatMapLeft<T>(Either<T, R> Function(L) f) => .right(value);

  @override
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) => onRight(value);

  @override
  R getOrElse(R Function() orElse) => value;

  @override
  L getOrElseLeft(L Function() orElse) => orElse();

  @override
  Either<L, R> inspect(void Function(R) f) {
    f(value);
    return this;
  }

  @override
  Either<L, R> inspectLeft(void Function(L) f) => this;

  @override
  Either<L, T> map<T>(T Function(R) f) => .right(f(value));

  @override
  Either<T, R> mapLeft<T>(T Function(L) f) => .right(value);

  @override
  Either<R, L> swap() => .left(value);

  @override
  Result<R> toResult(Object Function(L) mapErr) => .ok(value);

  @override
  Right<L, R> orElse(Right<L, R> Function() orElse) => this;

  @override
  Left<L, R> orElseLeft(Left<L, R> Function() orElse) => orElse();

  @override
  List<Object?> get props => [value];
}
