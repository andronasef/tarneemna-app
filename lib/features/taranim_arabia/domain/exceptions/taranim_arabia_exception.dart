abstract class TaranimArabiaException implements Exception {
  final String message;
  final dynamic cause;

  const TaranimArabiaException(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

class TaranimArabiaNetworkException extends TaranimArabiaException {
  final int? statusCode;

  const TaranimArabiaNetworkException(String message, {this.statusCode, dynamic cause})
      : super(message, cause);
}

class TaranimArabiaParsingException extends TaranimArabiaException {
  const TaranimArabiaParsingException(super.message, [super.cause]);
}

class TaranimArabiaNotFoundException extends TaranimArabiaException {
  final int? statusCode;

  const TaranimArabiaNotFoundException(super.message, [this.statusCode]);
}
