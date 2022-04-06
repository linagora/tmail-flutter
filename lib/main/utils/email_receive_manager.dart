
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rxdart/rxdart.dart';

class EmailReceiveManager {

  BehaviorSubject<EmailAddress?> _pendingEmailAddressInfo = BehaviorSubject.seeded(null);
  BehaviorSubject<EmailAddress?> get pendingEmailAddressInfo => _pendingEmailAddressInfo;

  Stream<Uri?> get receivingSharingStream {
    return Rx.merge([
      Stream.fromFuture(ReceiveSharingIntent.getInitialTextAsUri()),
      ReceiveSharingIntent.getTextStreamAsUri()
    ]);
  }
  Stream<List<SharedMediaFile>> get receivingSharingStream2 {
    return Rx.merge([
      Stream.fromFuture(ReceiveSharingIntent.getInitialMedia()),
      ReceiveSharingIntent.getMediaStream()
    ]);
  }

  void setPendingEmailAddress(EmailAddress emailAddress) async {
    clearPendingEmailAddress();
    _pendingEmailAddressInfo.add(emailAddress);
  }

  void clearPendingEmailAddress() {
    if(_pendingEmailAddressInfo.isClosed) {
      _pendingEmailAddressInfo = BehaviorSubject.seeded(null);
    } else {
      _pendingEmailAddressInfo.add(null);
    }
  }

  void closeEmailReceiveManagerStream() {
    _pendingEmailAddressInfo.close();
  }
}