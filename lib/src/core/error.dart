sealed class GeminiBridgeException implements Exception {
  GeminiBridgeException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class InvalidApiKeyException extends GeminiBridgeException {
  InvalidApiKeyException(super.message);
}

final class QuotaExceededException extends GeminiBridgeException {
  QuotaExceededException(super.message);
}

final class GeminiServerException extends GeminiBridgeException {
  GeminiServerException(super.message);
}

GeminiBridgeException parseGeminiError(Map<String, dynamic> errorJson) {
  final message =
      errorJson['message'] as String? ?? 'An unknown Gemini API error occurred.';
  final status = errorJson['status'] as String?;

  switch (status) {
    case 'INVALID_ARGUMENT':
      if (message.toLowerCase().contains('api key')) {
        return InvalidApiKeyException(message);
      }
      return GeminiServerException(message);

    case 'RESOURCE_EXHAUSTED':
      return QuotaExceededException(message);

    default:
      return GeminiServerException(message);
  }
}