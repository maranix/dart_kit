import 'dart:async';
import 'package:daxle/src/result.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('isOk returns true', () {
      final result = Result<int, String>.ok(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('unwrap returns value', () {
      final result = Result<String, int>.ok('hello');
      expect(result.unwrap(), 'hello');
    });

    test('getOrElse returns value, ignores orElse', () {
      final result = Result<int, String>.ok(100);
      expect(result.getOrElse((e) => 0), 100);
    });

    test('map transforms value', () {
      final result = Result<int, String>.ok(2).map((x) => x * 3);
      expect(result.unwrap(), 6);
    });

    test('flatMap transforms value to new Result', () {
      final result = Result<int, String>.ok(5).flatMap((x) => Result.ok(x * 2));
      expect(result.unwrap(), 10);
    });

    test('mapErr leaves value unchanged', () {
      final result = Result<int, String>.ok(10).mapErr((e) => 'new error');
      expect(result.unwrap(), 10);
    });

    test('fold executes onOk', () {
      final result = Result<String, int>.ok('success');
      final folded = result.fold(onOk: (v) => 'ok $v', onErr: (e, _) => 'err');
      expect(folded, 'ok success');
    });

    test('orElse returns self', () {
      final result = Result<int, String>.ok(7);
      final fallback = Result<int, String>.ok(0);
      final output = result.orElse((e, s) => fallback);
      expect(output.unwrap(), 7);
    });

    test('expect returns value', () {
      final result = Result<String, int>.ok('value');
      expect(result.expect('fail'), 'value');
    });

    final exception = Exception('oops');

    test('isErr returns true', () {
      final result = Result<int, Exception>.err(exception);
      expect(result.isErr, isTrue);
      expect(result.isOk, isFalse);
    });

    test('unwrap throws original error', () {
      final result = Result<int, Exception>.err(exception);
      expect(() => result.unwrap(), throwsA(same(exception)));
    });

    test('getOrElse returns fallback', () {
      final result = Result<int, String>.err('error');
      expect(result.getOrElse((e) => 42), 42);
    });

    test('map leaves error unchanged', () {
      final result = Result<int, String>.err('error').map((v) => 'ok');
      expect(result.isErr, isTrue);
    });

    test('flatMap leaves error unchanged', () {
      final result = Result<int, String>.err('error').flatMap((v) => Result.ok('ok'));
      expect(result.isErr, isTrue);
    });

    test('mapErr transforms error', () {
      final result = Result<int, String>.err('fail').mapErr((e) => 'new error');
      expect(result.fold(onOk: (_) => 'ok', onErr: (e, _) => e), 'new error');
    });

    test('fold executes onErr', () {
      final result = Result<int, String>.err('err');
      final folded = result.fold(
        onOk: (_) => 'ok',
        onErr: (e, _) => 'error $e',
      );
      expect(folded, 'error err');
    });

    test('orElse executes fallback', () {
      final result = Result<int, String>.err('fail');
      final fallback = Result<int, String>.ok(99);
      final output = result.orElse((e, s) => fallback);
      expect(output.unwrap(), 99);
    });

    test('expect throws StateError with message', () {
      final result = Result<int, String>.err('err');
      try {
        result.expect('expected failure');
        fail("expect should have thrown");
      } on StateError catch (e) {
        expect(e.message.startsWith("Result.err: expected failure"), isTrue);
      }
    });

    group('from', () {
      test('returns Ok on success', () {
        final result = Result.from<int, String>(() => 123);
        expect(result.unwrap(), 123);
      });

      test('returns Err on Exception with matching type', () {
        final result = Result.from<int, String>(() => throw 'fail');
        expect(result.isErr, isTrue);
        expect(result.fold(onOk: (_) => '', onErr: (e, _) => e), 'fail');
      });

      test('rethrows Error', () {
        expect(
          () => Result.from<int, String>(() => throw StateError('error')),
          throwsA(isA<StateError>()),
        );
      });

      test('uses onError to handle exceptions', () {
        final result = Result.from<int, String>(
          () => throw Exception('fail'),
          onError: (e) => 'handled',
        );
        expect(result.isErr, isTrue);
        expect(result.fold(onOk: (_) => '', onErr: (e, _) => e), 'handled');
      });

      test('throws TypeError on invalid cast', () {
        expect(
          () => Result.from<int, int>(() => throw 'fail'),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('fromAsync', () {
      test('returns Ok on success', () async {
        final result = await Result.fromAsync<String, String>(() async => 'async');
        expect(result.unwrap(), 'async');
      });

      test('returns Err on Exception with matching type', () async {
        final result = await Result.fromAsync<int, String>(
          () async => throw 'fail',
        );
        expect(result.isErr, isTrue);
        expect(result.fold(onOk: (_) => '', onErr: (e, _) => e), 'fail');
      });

      test('rethrows Error', () async {
        await expectLater(
          () => Result.fromAsync<int, String>(
            () async => throw StateError('error'),
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('uses onError to handle exceptions', () async {
        final result = await Result.fromAsync<int, String>(
          () async => throw Exception('fail'),
          onError: (e) => 'handled',
        );
        expect(result.isErr, isTrue);
        expect(result.fold(onOk: (_) => '', onErr: (e, _) => e), 'handled');
      });

      test('throws TypeError on invalid cast', () async {
        await expectLater(
          () => Result.fromAsync<int, int>(() async => throw 'fail'),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('toResult', () {
      test('converts Future<T> to Result<T, E>', () async {
        final future = Future.value(5);
        final result = await future.toResult<String>();
        expect(result.unwrap(), 5);
      });

      test('captures exceptions', () async {
        final future = Future<int>.error(Exception('fail'));
        final result = await future.toResult<Object>();
        expect(result.isErr, isTrue);
      });
    });

    test('Ok equality and props', () {
      final a = Result<int, String>.ok(1);
      final b = Result<int, String>.ok(1);
      final c = Result<int, String>.ok(2);

      expect(a, b);
      expect(a == c, isFalse);
      expect(a.props, [1]);
    });

    test('Err equality and props', () {
      final e1 = Result<int, String>.err('fail');
      final e2 = Result<int, String>.err('fail');
      final e3 = Result<int, String>.err('other');

      expect(e1, e2);
      expect(e1 == e3, isFalse);
      expect(e1.props, ['fail']);
    });

    test('Ok with null value', () {
      final result = Result<int?, String>.ok(null);
      expect(result.isOk, isTrue);
      expect(result.unwrap(), isNull);
    });

    test('Err with stack trace', () {
      final trace = StackTrace.current;
      final err = Err<int, String>('fail', trace);
      expect(err.stackTrace, trace);
    });

    test('transforms Ok to Option correctly', () {
      final result = Result<int, String>.ok(1);
      final option = result.toOption();

      expect(option.isSome, isTrue);
      expect(option.unwrap(), result.unwrap());
    });

    test('transforms Err to Option correctly', () {
      final error = Exception("oops");

      final result = Result<int, Exception>.err(error);
      final option = result.toOption();

      expect(() => result.unwrap(), throwsA(same(error)));
      expect(option.isNone, isTrue);
      expect(() => option.unwrap(), throwsStateError);
    });

    test('transforms Ok to Either correctly', () {
      final result = Result<int, String>.ok(1);
      final either = result.toEither();

      expect(either.isRight, isTrue);
      expect(either.unwrap(), result.unwrap());
    });

    test('transforms Err to Either correctly', () {
      final error = Exception("oops");

      final result = Result<int, Exception>.err(error);
      final either = result.toEither();

      expect(() => result.unwrap(), throwsA(same(error)));
      expect(either.isLeft, isTrue);
      expect(either.unwrapLeft(), same(error));
    });
  });
}
