import 'package:daxle/daxle.dart';
import 'package:meta/meta.dart';

/// {@template lazy}
/// A container for a value that is computed lazily.
///
/// The computation is performed only when the value is first accessed.
/// The result is then memoized and returned on subsequent accesses.
///
/// This is useful for expensive computations that may not always be needed,
/// or for deferring the execution of a computation until it is actually required.
///
/// Example:
/// ```dart
/// final lazyValue = Lazy(() {
///   print("Computing...");
///   return 42;
/// });
///
/// print("Before access");
/// print(lazyValue.value); // Prints "Computing..." then "42"
/// print(lazyValue.value); // Prints "42" (no "Computing...")
/// ```
/// {@endtemplate}
sealed class Lazy<T> {
  /// {@macro lazy}
  factory Lazy(T Function() factory) = _LazyImpl<T>;

  /// Returns the value of this [Lazy] instance.
  ///
  /// If the value has not been computed yet, the factory function is executed,
  /// the result is memoized, and then returned.
  /// If the value has already been computed, the memoized result is returned immediately.
  T get value;

  /// Returns `true` if the value has been evaluated, `false` otherwise.
  bool get isEvaluated;

  /// Transforms the value of this [Lazy] instance using the given function [f].
  ///
  /// The resulting [Lazy] instance will also be lazy. The function [f] will
  /// only be executed when the new [Lazy] instance's value is accessed.
  @useResult
  Lazy<R> map<R>(R Function(T value) f);

  /// Transforms the value of this [Lazy] instance using the given function [f],
  /// which returns another [Lazy] instance.
  ///
  /// The resulting [Lazy] instance will be flattened.
  @useResult
  Lazy<R> flatMap<R>(Lazy<R> Function(T value) f);

  /// Executes [f] on the value when it is evaluated.
  ///
  /// Returns a new [Lazy] that behaves exactly like this one, but with the side effect [f].
  /// The side effect runs only when the returned [Lazy] is evaluated.
  @useResult
  Lazy<T> inspect(void Function(T value) f);

  /// Evaluates the lazy value and returns it wrapped in a [Result].
  ///
  /// If the evaluation throws an exception, it returns [Result.err].
  /// Otherwise, it returns [Result.ok].
  @useResult
  Result<T, Exception> toResult();

  /// Evaluates the lazy value and returns it wrapped in an [Option].
  ///
  /// If the evaluation throws an exception or returns null (if T is nullable),
  /// it usually returns [Option.some] unless specific logic handles nulls.
  /// However, standard `Option` usually wraps non-nulls.
  /// Here we assume if it throws, we might return [Option.none] or rethrow depending on design.
  /// Given existing patterns, let's catch exceptions and return None?
  /// Or just standard "wrap value".
  ///
  /// Let's align with: catch exception -> None? Or just wrap the value?
  /// A safer approach generally is capturing success.
  /// Let's implement simply: value -> Some(value).
  @useResult
  Option<T> toOption();

  /// Evaluates the lazy value and returns it wrapped in an [Either].
  ///
  /// The [left] factory is used to produce the Left value if evaluation throws.
  @useResult
  Either<Exception, T> toEither();
}

class _LazyImpl<T> implements Lazy<T> {
  _LazyImpl(this._factory);

  final T Function() _factory;
  late final T _value = _factory();
  bool _isEvaluated = false;

  @override
  T get value {
    if (!_isEvaluated) {
      _isEvaluated = true;
    }
    return _value;
  }

  @override
  bool get isEvaluated => _isEvaluated;

  @override
  Lazy<R> map<R>(R Function(T value) f) {
    return Lazy(() => f(value));
  }

  @override
  Lazy<R> flatMap<R>(Lazy<R> Function(T value) f) {
    return Lazy(() => f(value).value);
  }

  @override
  Lazy<T> inspect(void Function(T value) f) {
    return Lazy(() {
      final v = value;
      f(v);
      return v;
    });
  }

  @override
  Result<T, Exception> toResult() {
    try {
      return Result.ok(value);
    } on Exception catch (e) {
      return Result.err(e);
    } catch (e) {
      return Result.err(Exception(e.toString()));
    }
  }

  @override
  Option<T> toOption() {
    try {
      return Option.some(value);
    } catch (_) {
      return Option.none();
    }
  }

  @override
  Either<Exception, T> toEither() {
    try {
      return Either.right(value);
    } on Exception catch (e) {
      return Either.left(e);
    } catch (e) {
      return Either.left(Exception(e.toString()));
    }
  }
}
