import 'dart:async';
import 'package:daxle/src/result.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('isOk returns true', () {
      final result = Result.ok(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('unwrap returns value', () {
      final result = Result.ok('hello');
      expect(result.unwrap(), 'hello');
    });

    test('getOrElse returns value, ignores orElse', () {
      final result = Result.ok(100);
      expect(result.getOrElse(() => 0), 100);
    });

    test('map transforms value', () {
      final result = Result.ok(2).map((x) => x * 3);
      expect(result.unwrap(), 6);
    });

    test('flatMap transforms value to new Result', () {
      final result = Result.ok(5).flatMap((x) => Result.ok(x * 2));
      expect(result.unwrap(), 10);
    });

    test('mapErr leaves value unchanged', () {
      final result = Result.ok(10).mapErr((e) => 'new error');
      expect(result.unwrap(), 10);
    });

    test('fold executes onOk', () {
      final result = Result.ok('success');
      final folded = result.fold(onOk: (v) => 'ok $v', onErr: (e, _) => 'err');
      expect(folded, 'ok success');
    });

    test('orElse returns self', () {
      final result = Result.ok(7);
      final fallback = Result.ok(0);
      final output = result.orElse(() => fallback);
      expect(output.unwrap(), 7);
    });

    test('expect returns value', () {
      final result = Result.ok('value');
      expect(result.expect('fail'), 'value');
    });

    final exception = Exception('oops');

    test('isErr returns true', () {
      final result = Result.err(exception);
      expect(result.isErr, isTrue);
      expect(result.isOk, isFalse);
    });

    test('unwrap throws original error', () {
      final result = Result.err(exception);
      expect(() => result.unwrap(), throwsA(same(exception)));
    });

    test('getOrElse returns fallback', () {
      final result = Result.err('error');
      expect(result.getOrElse(() => 42), 42);
    });

    test('map leaves error unchanged', () {
      final result = Result.err('error').map((v) => 'ok');
      expect(result.isErr, isTrue);
    });

    test('flatMap leaves error unchanged', () {
      final result = Result.err('error').flatMap((v) => Result.ok('ok'));
      expect(result.isErr, isTrue);
    });

    test('mapErr transforms error', () {
      final result = Result.err('fail').mapErr((e) => 'new error');
      expect(result.fold(onOk: (_) => 'ok', onErr: (e, _) => e), 'new error');
    });

    test('fold executes onErr', () {
      final result = Result.err('err');
      final folded = result.fold(
        onOk: (_) => 'ok',
        onErr: (e, _) => 'error $e',
      );
      expect(folded, 'error err');
    });

    test('orElse executes fallback', () {
      final result = Result.err('fail');
      final fallback = Result.ok(99);
      final output = result.orElse(() => fallback);
      expect(output.unwrap(), 99);
    });

    test('expect throws StateError with message', () {
      final result = Result.err('err');
      try {
        result.expect('expected failure');
      } on StateError catch (e) {
        expect(e.message.startsWith("Result.err: expected failure"), isTrue);
      }
    });

    test('returns Ok on success', () {
      final result = Result.from(() => 123);
      expect(result.unwrap(), 123);
    });

    test('returns Err on Exception', () {
      final result = Result.from(() => throw Exception('fail'));
      expect(result.isErr, isTrue);
    });

    test('rethrows Error', () {
      expect(
        () => Result.from(() => throw StateError('error')),
        throwsA(isA<StateError>()),
      );
    });

    test('returns Ok on success', () async {
      final result = await Result.fromAsync(() async => 'async');
      expect(result.unwrap(), 'async');
    });

    test('returns Err on Exception', () async {
      final result = await Result.fromAsync(
        () async => throw Exception('fail'),
      );
      expect(result.isErr, isTrue);
    });

    test('rethrows Error', () async {
      await expectLater(
        () => Result.fromAsync(() async => throw StateError('error')),
        throwsA(isA<StateError>()),
      );
    });

    test('toResult converts Future<T> to Result<T>', () async {
      final future = Future.value(5);
      final result = await future.toResult();
      expect(result.unwrap(), 5);
    });

    test('toResult captures exceptions', () async {
      final future = Future<int>.error(Exception('fail'));
      final result = await future.toResult();
      expect(result.isErr, isTrue);
    });

    test('Ok equality and props', () {
      final a = Result.ok(1);
      final b = Result.ok(1);
      final c = Result.ok(2);

      expect(a, b);
      expect(a == c, isFalse);
      expect(a.props, [1]);
    });

    test('Err equality and props', () {
      final e1 = Result.err('fail');
      final e2 = Result.err('fail');
      final e3 = Result.err('other');

      expect(e1, e2);
      expect(e1 == e3, isFalse);
      expect(e1.props, ['fail']);
    });

    test('Ok with null value', () {
      final result = Result.ok(null);
      expect(result.isOk, isTrue);
      expect(result.unwrap(), isNull);
    });

    test('Err with stack trace', () {
      final trace = StackTrace.current;
      final err = Err('fail', trace);
      expect(err.stackTrace, trace);
    });

    test('transforms Ok correctly', () {
      final result = Result.ok(1);
      final option = result.toOption();

      expect(option.isSome, isTrue);
      expect(option.unwrap(), result.unwrap());
    });

    test('transforms Err correctly', () {
      final error = Exception("oops");

      final result = Result.err(error);
      final option = result.toOption();

      expect(() => result.unwrap(), throwsA(same(error)));
      expect(option.isNone, isTrue);
      expect(() => option.unwrap(), throwsStateError);
    });

    test('transforms Ok correctly', () {
      final result = Result.ok(1);
      final either = result.toEither();

      expect(either.isRight, isTrue);
      expect(either.unwrap(), result.unwrap());
    });

    test('transforms Err correctly', () {
      final error = Exception("oops");

      final result = Result.err(error);
      final either = result.toEither<Exception>();

      expect(() => result.unwrap(), throwsA(same(error)));
      expect(either.isLeft, isTrue);
      expect(either.unwrapLeft(), same(error));
    });
  });
}
