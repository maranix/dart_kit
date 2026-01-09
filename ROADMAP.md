# dart_kit — Feature Roadmap & Tracker

A living document to track implemented and planned features for `dart_kit`.

---

## 📦 Core Goal

Provide commonly missing utilities and abstractions inspired by other languages
to help write safer, more expressive, and predictable Dart code.

---

## ✅ Implemented Features

> Result represents success/failure semantics  
> Either is a generic sum type without implied meaning

---

- [x] Option
  - [x] Some
  - [x] None
  - [x] isSome / isNone
  - [x] unwrap / expect
  - [x] map
  - [x] flatMap
  - [x] fold
  - [x] getOrElse
  - [x] filter
  - [x] inspect
  - [x] contains
  - [x] from
  - [x] fromAsync
  - [x] orElse
  - [ ] toResult

- [x] Result
  - [x] Ok
  - [x] Err
  - [x] map
  - [x] mapErr
  - [x] flatMap
  - [x] fold
  - [x] getOrElse
  - [x] unwrap / unwrapErr
  - [x] isOk / isErr
  - [x] from
  - [x] fromAsync
  - [x] orElse
  - [ ] toEither
  - [ ] toOption

### Either<L, R>
- [ ] Either
  - [ ] Left
  - [ ] Right
  - [ ] isLeft / isRight
  - [ ] swap
  - [ ] fold
  - [ ] getOrElse (for Right)
  - [ ] getOrElseLeft (for Left)
  @override
  bool get stringify => true;

  @override
  List<Object> get props => switch (this) {
    Some<T>(:final value) => [value],
    None() => [],
  };
  - [ ] map (map Right value)
  - [ ] mapLeft (map Left value)
  - [ ] flatMap (chain Right value)
  - [ ] flatMapLeft (chain Left value)
  - [ ] contains (check Right)
  - [ ] containsLeft (check Left)
  - [ ] inspect (for debugging Right)
  - [ ] inspectLeft (for debugging Left)
  - [ ] from (construct from nullable or callback)
  - [ ] fromAsync (construct from Future)
  - [ ] orElse (default Right value) 
  - [ ] orElseLeft (default Left value)
  - [ ] toResult (convert Either<L, R> → Result<R, L>)
  - [ ] toOption (Right → Some, Left → None)
  - [ ] toOptionLeft (Left → Some, Right → None)
---

## 🧩 Planned Core Types

### Functional Types
- [ ] Unit
- [ ] Try<T>
- [ ] Lazy<T>

### Async Utilities
- [ ] Task<T>
- [ ] AsyncResult<T, E>
- [ ] Result extensions for `Future`

---

## 📚 Collection Utilities

- [ ] NonEmptyList<T>
- [ ] Safe collection extensions
  - [ ] firstOrNone
  - [ ] singleOrNone
  - [ ] mapOrNone

---

## 🧠 Validation & Errors

- [ ] Validated<T, E>
- [ ] Error base types
  - [ ] Failure
  - [ ] ValidationError
  - [ ] UnexpectedError

---

## ✨ Quality of Life

- [ ] Equality & hashing helpers
- [ ] Debug helpers
- [ ] Function extensions
  - [ ] pipe
  - [ ] tap
  - [ ] compose

---

## 🗺 Suggested Release Phases

### v0.1.x
- Option
  - Core extensions
- Result
  - Core extensions
- Either
  - Core extensions

### v0.2.x
- Try
- Unit
- Function helpers

### v0.3.x
- Async utilities
- Validation
- NonEmptyList

---

## 📝 Notes

- Keep APIs idiomatic to Dart
- Prefer explicit naming over cleverness
- Avoid overengineering
