import 'package:daxle/daxle.dart';

void main() {
  // --- Option ---
  Option<int> someValue = Option.some(10);
  Option<int> noValue = Option.none();

  print('someValue.isSome: ${someValue.isSome}');
  print('noValue.isNone: ${noValue.isNone}');

  final mapped = someValue.map((value) => 'Value is $value');
  print("someValue.map((v) => 'Value is \$v'): ${mapped.unwrap()}");

  final value = noValue.getOrElse(() => 0);
  print('noValue.getOrElse(() => 0): $value');
  print('');

  // --- Result ---
  Result<int> success = Result.ok(100);
  Result<int> failure = Result.err('Something went wrong');

  print('success.isOk: ${success.isOk}');
  print('failure.isErr: ${failure.isErr}');

  final mappedSuccess = success.map((v) => v * 2);
  print('success.map((v) => v * 2): ${mappedSuccess.unwrap()}');

  final resultValue = failure.getOrElse(() => 0);
  print('failure.getOrElse(() => 0): $resultValue');
  print('');

  // --- Either ---
  Either<String, int> parseInput(String input) {
    return int.tryParse(input) != null
        ? Either.right(int.parse(input))
        : Either.left('Not a number');
  }

  Either<String, int> numericInput = parseInput('123');
  Either<String, int> textInput = parseInput('abc');

  print("parseInput('123').isRight: ${numericInput.isRight}");
  print("parseInput('abc').isLeft: ${textInput.isLeft}");

  final multiplied = numericInput.map((number) => number * 10);
  multiplied.fold(
    (l) => null,
    (r) => print('numericInput.map((n) => n * 10): Multiplied value: $r'),
  );
}
