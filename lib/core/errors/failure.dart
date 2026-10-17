/// Base sealed class for all strongly-typed domain & infrastructure failures.
sealed class Failure {
  const Failure({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType(message: $message, cause: $cause)';
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(String message, [Object? cause])
      : super(message: message, cause: cause);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(String message, [Object? cause])
      : super(message: message, cause: cause);
}

final class StorageFailure extends Failure {
  const StorageFailure(String message, [Object? cause])
      : super(message: message, cause: cause);
}

final class SecurityFailure extends Failure {
  const SecurityFailure(String message, [Object? cause])
      : super(message: message, cause: cause);
}

final class BackupFailure extends Failure {
  const BackupFailure(String message, [Object? cause])
      : super(message: message, cause: cause);
}

final class NotificationFailure extends Failure {
  const NotificationFailure(String message, [Object? cause])
      : super(message: message, cause: cause);
}
