enum MailboxSubscribeState {
  enabled,
  disabled;
  
  String get keyValue {
      switch(this) {
          case MailboxSubscribeState.enabled:
            return 'enabled';
          case MailboxSubscribeState.disabled:
            return 'disabled';
    }
  }
}