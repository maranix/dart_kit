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
- [x] Either
  - [x] Left
  - [x] Right
  - [x] isLeft / isRight
  - [x] swap
  - [x] fold
  - [x] getOrElse (for Right)
  - [x] getOrElseLeft (for Left)
  - [x] map (map Right value)
  - [x] mapLeft (map Left value)
  - [x] flatMap (chain Right value)
  - [x] flatMapLeft (chain Left value)
  - [x] contains (check Right)
  - [x] containsLeft (check Left)
  - [x] inspect (for debugging Right)
  - [x] inspectLeft (for debugging Left)
  - [x] orElse (default Right value) 
  - [x] orElseLeft (default Left value)
  - [x] toResult (convert Either<L, R> → Result<R, L>)
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
