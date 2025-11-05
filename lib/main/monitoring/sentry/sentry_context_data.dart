class SentryContextData {
  final String? errorType;
  final String? errorMessage;
  final int? statusCode;
  final Map<String, dynamic>? additionalInfo;
  final DateTime timestamp;

  SentryContextData({
    this.errorType,
    this.errorMessage,
    this.statusCode,
    this.additionalInfo,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  Map<String, dynamic> toMap() {
    return {
      if (errorType != null) 'errorType': errorType,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (statusCode != null) 'statusCode': statusCode,
      if (additionalInfo != null && additionalInfo!.isNotEmpty)
        'additionalInfo': additionalInfo,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
