enum SpamReportState {
  enabled,
  disabled;
  
  String get keyValue {
      switch(this) {
          case SpamReportState.enabled:
            return 'enabled';
          case SpamReportState.disabled:
            return 'disabled';
    }
  }
}