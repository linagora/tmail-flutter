class WorkplaceCreateIntentException implements Exception {}

class WorkplaceExchangeTokenException implements Exception {}

class DriveIntentErrorException implements Exception {}

class DriveIntentPageLoadException implements Exception {
  final String reason;

  DriveIntentPageLoadException(this.reason);

  @override
  String toString() => 'DriveIntentPageLoadException: $reason';
}

class DriveIntentTimeoutException implements Exception {}

class WorkplaceNoIntentClientException implements Exception {}

class DriveDownloadNullAttachmentException implements Exception {}

class DriveDownloadInsecureLinkException implements Exception {}

class DriveDownloadEmptyResponseException implements Exception {}

/// The response body ended before the declared `content-length` was reached,
/// so the staged file is a truncated copy of the document.
class DriveDownloadIncompleteException implements Exception {
  final int received;
  final int expected;

  DriveDownloadIncompleteException({
    required this.received,
    required this.expected,
  });

  @override
  String toString() =>
      'DriveDownloadIncompleteException: received $received of $expected bytes';
}
