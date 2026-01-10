## 1.1.0

- Added `toRecord` method to `Result` to destructure it into a record of `(T Function() ok, E Function() err)`.
- Refactored `Result<T>` to `Result<T, E>` to support type-safe errors. (2026-01-10)
  - This is a breaking change that improves error handling by allowing the error type to be specified.
  - Updated `from` and `fromAsync` methods on `Result` to support generic error types and an `onError` callback.
  - Updated `toResult` methods on `Either` and `Option` to be compatible with the new `Result<T, E>` type.

## 1.0.0

- Initial version. (2026-01-10)
  - Implemented `Either` type for representing success or failure.
  - Implemented `Option` type for representing the presence or absence of a value.
  - Implemented `Result` type for representing a result of an operation that can either succeed or fail.
