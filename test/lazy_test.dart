import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

void main() {
  group('Lazy', () {
    test('computes value lazily and only once', () {
      int computationCount = 0;
      final lazy = Lazy(() {
        computationCount++;
        return 42;
      });

      expect(computationCount, 0);
      expect(lazy.isEvaluated, isFalse);

      expect(lazy.value, 42);
      expect(computationCount, 1);
      expect(lazy.isEvaluated, isTrue);

      expect(lazy.value, 42);
      expect(computationCount, 1);
    });

    test('supports async operations (Lazy<Future>)', () async {
      int computationCount = 0;
      final lazy = Lazy(() async {
        computationCount++;
        await Future.delayed(const Duration(milliseconds: 10));
        return 'done';
      });

      expect(computationCount, 0);
      expect(lazy.isEvaluated, isFalse);

      final result1 = await lazy.value;
      expect(result1, 'done');
      expect(computationCount, 1);
      expect(lazy.isEvaluated, isTrue);

      final result2 = await lazy.value;
      expect(result2, 'done');
      expect(computationCount, 1);
    });

    test('map transforms value', () {
      final lazy = Lazy(() => 10);
      final lazyString = lazy.map((val) => 'Value: $val');

      expect(lazy.isEvaluated, isFalse);
      expect(lazyString.isEvaluated, isFalse);

      expect(lazyString.value, 'Value: 10');
      // Mapping creates a new Lazy, original executes 'f(value)' which calls 'value'.
      // So checking lazy.isEvaluated should be true after lazyString.value access.
      expect(lazy.isEvaluated, isTrue);
    });

    test('flatMap chains Lazy', () {
      final lazy = Lazy(() => 10);
      final lazyResult = lazy.flatMap((val) => Lazy(() => val * 2));

      expect(lazyResult.value, 20);
    });

    test('toResult returns Ok on success', () {
      final lazy = Lazy(() => 10);
      final result = lazy.toResult();
      expect(result, isA<Ok<int, Exception>>());
      expect(result.unwrap(), 10);
    });

    test('toResult returns Err on exception', () {
      final lazy = Lazy<int>(() => throw Exception('oops'));
      final result = lazy.toResult();
      expect(result, isA<Err<int, Exception>>());
      expect(result.isErr, isTrue);
    });

    test('toOption returns Some on success', () {
      final lazy = Lazy(() => 10);
      final option = lazy.toOption();
      expect(option, isA<Some<int>>());
      expect(option.unwrap(), 10);
    });

    test('toOption returns None on exception', () {
      final lazy = Lazy<int>(() => throw Exception('oops'));
      final option = lazy.toOption();
      expect(option, isA<None<int>>());
    });

    test('toEither returns Right on success', () {
      final lazy = Lazy(() => 10);
      final either = lazy.toEither();
      expect(either.isRight, isTrue);
      expect(either.unwrap(), 10);
    });

    test('toEither returns Left on exception', () {
      final lazy = Lazy<int>(() => throw Exception('oops'));
      final either = lazy.toEither();
      expect(either.isLeft, isTrue);
    });

    test('inspect runs side effect on evaluation', () {
      int sideEffectCount = 0;
      final lazy = Lazy(() => 10);
      final inspected = lazy.inspect((val) {
        sideEffectCount++;
        expect(val, 10);
      });

      expect(sideEffectCount, 0);
      expect(inspected.isEvaluated, isFalse);

      expect(inspected.value, 10);
      expect(sideEffectCount, 1);
      expect(inspected.isEvaluated, isTrue);
    });

    test('inspect does NOT re-evaluate original factory', () {
      int computationCount = 0;
      final lazy = Lazy(() {
        computationCount++;
        return 99;
      });

      // Evaluate first
      expect(lazy.value, 99);
      expect(computationCount, 1);

      // Create inspect
      final inspected = lazy.inspect((_) {});

      // Evaluate inspect
      expect(inspected.value, 99);

      // Ensure computation count is still 1
      expect(computationCount, 1);
    });
  });
}
