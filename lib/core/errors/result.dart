import 'package:aula/core/errors/failure.dart';

/// Lightweight functional Result monad for clean error handling.
sealed class Result<T> {
  const Result();

  factory Result.ok(T value) = Success<T>;
  factory Result.failure(Failure failure) = Error<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T get value => (this as Success<T>).value;
  Failure get failure => (this as Error<T>).failure;

  T? get dataOrNull => switch (this) {
        Success(:final value) => value,
        Error() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success() => null,
        Error(:final failure) => failure,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) =>
      switch (this) {
        Success(:final value) => success(value),
        Error(failure: final f) => failure(f),
      };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Success(:final value) => Success(transform(value)),
        Error(:final failure) => Error(failure),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  @override
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

final class Error<T> extends Result<T> {
  const Error(this.failure);
  @override
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Error<T> && other.failure == failure);

  @override
  int get hashCode => failure.hashCode;
}
