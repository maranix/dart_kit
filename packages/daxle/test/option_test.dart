import 'package:daxle/src/either.dart';
import 'package:daxle/src/option.dart';
import 'package:daxle/src/result.dart';
import 'package:test/test.dart';

void main() {
  group('Option', () {
    test('Some initializes with value', () {
      final Option<int> option = .some(42);

      expect(option.isSome, isTrue);
      expect(option.isNone, isFalse);
      expect(option.unwrap(), equals(42));
    });

    test('None initializes correctly', () {
      final Option<int> option = .none();

      expect(option.isSome, isFalse);
      expect(option.isNone, isTrue);
      expect(() => option.unwrap(), throwsStateError);
    });

    test('Some equality', () {
      final Option<int> a = .some(1);
      final Option<int> b = .some(1);
      final Option<int> c = .some(2);

      expect(a, equals(b));
      expect(a == c, isFalse);
    });

    test('None equality', () {
      final Option<int> a = .none();
      final Option<String> b = .none();

      expect(a, equals(b)); // None is equal regardless of T
    });

    test('Some vs None equality', () {
      final Option<int> a = .some(1);
      final Option<int> b = .none();

      expect(a == b, isFalse);
    });

    test('unwrap returns value for Some', () {
      final Option<int> option = .some(10);
      expect(option.unwrap(), equals(10));
    });

    test('unwrap throws for None', () {
      final Option<int> option = .none();
      expect(() => option.unwrap(), throwsStateError);
    });

    test('expect returns value for Some', () {
      final Option<int> option = .some(7);
      expect(option.expect('fail'), equals(7));
    });

    test('expect throws with message for None', () {
      final Option<int> option = .none();
      final msg = 'Custom error';
      expect(
        () => option.expect(msg),
        throwsA(
          predicate((e) {
            return e is StateError && e.message == msg;
          }),
        ),
      );
    });
    test('getOrElse returns value from Some', () {
      final Option<int> option = .some(5);
      expect(option.getOrElse(() => 99), equals(5));
    });

    test('getOrElse returns fallback from None', () {
      final Option<int> option = .none();
      expect(option.getOrElse(() => 99), equals(99));
    });

    test('map transforms Some', () {
      final Option<int> option = .some(3);
      final Option<String> mapped = option.map((v) => 'Value $v');

      expect(mapped.isSome, isTrue);
      expect(mapped.unwrap(), equals('Value 3'));
    });

    test('map returns None for None', () {
      final Option<int> option = .none();
      final Option<String> mapped = option.map((v) => 'Value $v');

      expect(mapped.isNone, isTrue);
    });

    test('flatMap transforms Some to Option', () {
      final Option<int> option = .some(3);
      final Option<String> result = option.flatMap((v) => Option.some('V$v'));

      expect(result.isSome, isTrue);
      expect(result.unwrap(), equals('V3'));
    });

    test('flatMap returns None for None', () {
      final Option<int> option = .none();
      final Option<String> result = option.flatMap((v) => Option.some('V$v'));

      expect(result.isNone, isTrue);
    });

    test('inspect executes side effect on Some', () {
      final Option<int> option = .some(5);
      var flag = false;

      final returned = option.inspect((v) {
        expect(v, equals(5));
        flag = true;
      });

      expect(flag, isTrue);
      expect(returned, equals(option)); // inspect returns original Option
    });

    test('inspect does nothing on None', () {
      final Option<int> option = .none();
      var flag = false;

      final returned = option.inspect((v) => flag = true);

      expect(flag, isFalse);
      expect(returned.isNone, isTrue);
    });

    test('contains returns true if value matches', () {
      expect(Option.some(7).contains(7), isTrue);
    });

    test('contains returns false if value differs', () {
      expect(Option.some(7).contains(8), isFalse);
    });

    test('contains returns false for None', () {
      expect(Option<int>.none().contains(7), isFalse);
    });
    test('filter keeps Some if predicate true', () {
      final Option<int> option = .some(10);
      final filtered = option.filter((v) => v > 5);

      expect(filtered.isSome, isTrue);
      expect(filtered.unwrap(), equals(10));
    });

    test('filter removes Some if predicate false', () {
      final Option<int> option = .some(2);
      final filtered = option.filter((v) => v > 5);

      expect(filtered.isNone, isTrue);
    });

    test('filter on None returns None', () {
      final Option<int> option = .none();
      final filtered = option.filter((v) => true);

      expect(filtered.isNone, isTrue);
    });
    test('fold executes onSome for Some', () {
      final Option<int> option = .some(10);
      final result = option.fold(onSome: (v) => v * 2, onNone: () => 0);

      expect(result, equals(20));
    });

    test('fold executes onNone for None', () {
      final Option<int> option = .none();
      final result = option.fold(onSome: (v) => v * 2, onNone: () => 0);

      expect(result, equals(0));
    });
    test('map after flatMap works correctly', () {
      final option = Option.some(
        5,
      ).flatMap((v) => Option.some(v * 2)).map((v) => 'Value $v');

      expect(option.isSome, isTrue);
      expect(option.unwrap(), equals('Value 10'));
    });

    test('flatMap to None propagates None', () {
      final option = Option<int>.some(
        5,
      ).flatMap((_) => Option<int>.none()).map((v) => v * 2);

      expect(option.isNone, isTrue);
    });

    test('nested Option.some(Some(...)) unwrap behaves correctly', () {
      final nested = Option.some(Option.some(5));
      expect(nested.isSome, isTrue);
      expect(nested.unwrap().unwrap(), equals(5));
    });

    test('from returns Ok on success', () {
      final result = Option.from(() => 123);
      expect(result.unwrap(), 123);
    });

    test('from returns Err on Exception', () {
      final result = Option.from(() => throw Exception('fail'));
      expect(result.isNone, isTrue);
    });

    test('from rethrows Error types', () {
      expect(
        () => Option.from(() => throw StateError('error')),
        throwsA(isA<StateError>()),
      );
    });

    test('fromAsync returns Ok on success', () async {
      final result = await Option.fromAsync(() async => 'async');
      expect(result.unwrap(), 'async');
    });

    test('fromAsync returns None on Exception', () async {
      final result = await Option.fromAsync(
        () async => throw Exception('fail'),
      );
      expect(result.isNone, isTrue);
    });

    test('fromAsync rethrows Error types', () async {
      await expectLater(
        () => Option.fromAsync(() async => throw StateError('error')),
        throwsA(isA<StateError>()),
      );
    });

    test('toResult correctly transforms to Result', () {
      Option<int> opt = .some(5);
      final result = opt.toResult(() => 'error');

      expect(result, isA<Result<int, String>>());
      expect(result.isOk, isTrue);
      expect(result.unwrap(), equals(5));
    });

    test('toResult correctly transforms from None to Result', () {
      Option<int> opt = .none();
      final result = opt.toResult(() => Exception());

      expect(result, isA<Result<int, Exception>>());
      expect(result.isErr, isTrue);
      expect(() => result.unwrap(), throwsException);
    });


    test('toEither correctly transforms to Either', () {
      Option<int> opt = .some(5);
      final result = opt.toEither();

      expect(result, isA<Either>());
      expect(result.isRight, isTrue);
      expect(result.unwrap(), equals(5));
    });

    test('toEither correctly transforming from None to Either', () {
      Option<int> opt = .none();
      final result = opt.toEither(() => "success");

      expect(result, isA<Either>());
      expect(result.isLeft, isTrue);
      expect(result.unwrapLeft(), equals("success"));
    });
    test(
      'toEither throws when transforming from None to Either without callback',
      () {
        Option<int> opt = .none();
        expect(() => opt.toEither(), throwsStateError);
      },
    );
  });
}
