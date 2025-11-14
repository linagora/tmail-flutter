class SentryContextData {
  final String? errorType;
  final String? errorMessage;
  final int? statusCode;
  final String? source;
  final Map<String, dynamic>? additionalInfo;
  final DateTime timestamp;

  SentryContextData({
    this.source,
    this.errorType,
    this.errorMessage,
    this.statusCode,
    this.additionalInfo,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  Map<String, dynamic> toMap() {
    return {
      if (source != null) 'source': source,
      if (errorType != null) 'errorType': errorType,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (statusCode != null) 'statusCode': statusCode,
      if (additionalInfo?.isNotEmpty == true)
        'additionalInfo': additionalInfo,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
