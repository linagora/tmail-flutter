
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rxdart/rxdart.dart';

class EmailReceiveManager {
  BehaviorSubject<List<SharedMediaFile>> _pendingSharedFileInfo =
    BehaviorSubject.seeded(List.empty(growable: true));
  BehaviorSubject<List<SharedMediaFile>> get pendingSharedFileInfo =>
    _pendingSharedFileInfo;

  Stream<List<SharedMediaFile>> get receivingFileSharingStream =>
    ReceiveSharingIntent.instance.getMediaStream();

  void registerReceivingFileSharingStreamWhileAppClosed() {
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      setPendingFileInfo(value);

      ReceiveSharingIntent.instance.reset();
    });
  }

  void closeEmailReceiveManagerStream() {
    _pendingSharedFileInfo.close();
  }

  void setPendingFileInfo(List<SharedMediaFile> list) {
    _clearPendingFileInfo();
    _pendingSharedFileInfo.add(list);
  }

  void _clearPendingFileInfo() {
    if(_pendingSharedFileInfo.isClosed) {
      _pendingSharedFileInfo = BehaviorSubject.seeded(List.empty(growable: true));
    } else {
      _pendingSharedFileInfo.add(List.empty(growable: true));
    }
  }
}