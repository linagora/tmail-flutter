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

class DriveDownloadNullAttachmentException implements Exception {}

class DriveDownloadInsecureLinkException implements Exception {}

class DriveDownloadEmptyResponseException implements Exception {}