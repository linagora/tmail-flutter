enum SpamReportState {
  enabled,
  disabled,
}

extension SpamReportStateExtension on SpamReportState {

  String get keyValue {
    switch(this) {
      case SpamReportState.enabled:
        return 'enabled';
      case SpamReportState.disabled:
        return 'disabled';
    }
  }
}