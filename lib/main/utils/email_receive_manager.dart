
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/email_content.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rxdart/rxdart.dart';

class EmailReceiveManager {

  BehaviorSubject<EmailAddress?> _pendingEmailAddressInfo = BehaviorSubject.seeded(null);
  BehaviorSubject<EmailAddress?> get pendingEmailAddressInfo => _pendingEmailAddressInfo;

  BehaviorSubject<EmailContent?> _pendingEmailContentInfo = BehaviorSubject.seeded(null);
  BehaviorSubject<EmailContent?> get pendingEmailContentInfo => _pendingEmailContentInfo;

  BehaviorSubject<List<SharedMediaFile>> _pendingFileInfo = BehaviorSubject.seeded(List.empty(growable: true));
  BehaviorSubject<List<SharedMediaFile>> get pendingFileInfo => _pendingFileInfo;

  Stream<Uri?> get receivingSharingStream {
    return Rx.merge([
      Stream.fromFuture(ReceiveSharingIntent.getInitialTextAsUri()),
      ReceiveSharingIntent.getTextStreamAsUri()
    ]);
  }
  Stream<List<SharedMediaFile>> get receivingFileSharingStream {
    return Rx.merge([
      Stream.fromFuture(ReceiveSharingIntent.getInitialMedia()),
      ReceiveSharingIntent.getMediaStream()
    ]);
  }

  void setPendingEmailAddress(EmailAddress emailAddress) async {
    _clearPendingEmailAddress();
    _pendingEmailAddressInfo.add(emailAddress);
  }

  void setPendingEmailContent(EmailContent emailContent) async {
    _clearPendingEmailContent();
    _pendingEmailContentInfo.add(emailContent);
  }

  void _clearPendingEmailContent() {
    if (_pendingEmailContentInfo.isClosed) {
      _pendingEmailContentInfo = BehaviorSubject.seeded(null);
    } else {
      _pendingEmailContentInfo.add(null);
    }
  }

  void _clearPendingEmailAddress() {
    if(_pendingEmailAddressInfo.isClosed) {
      _pendingEmailAddressInfo = BehaviorSubject.seeded(null);
    } else {
      _pendingEmailAddressInfo.add(null);
    }
  }

  void closeEmailReceiveManagerStream() {
    _pendingEmailAddressInfo.close();
    _pendingEmailContentInfo.close();
    _pendingFileInfo.close();
  }

  void setPendingFileInfo(List<SharedMediaFile> list) async {
    _clearPendingFileInfo();
    _pendingFileInfo.add(list);
  }

  void _clearPendingFileInfo() {
    if(_pendingFileInfo.isClosed) {
      _pendingFileInfo = BehaviorSubject.seeded(List.empty(growable: true));
    } else {
      _pendingFileInfo.add(List.empty(growable: true));
    }
  }
}