import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rxdart/rxdart.dart';

class EmailReceiveManager {
  BehaviorSubject<List<SharedMediaFile>> _pendingSharedFileInfo =
    BehaviorSubject.seeded(List.empty(growable: true));
  BehaviorSubject<List<SharedMediaFile>> get pendingSharedFileInfo =>
    _pendingSharedFileInfo;

  StreamSubscription<List<SharedMediaFile>>? _mediaStreamSubscription;

  /// Buffers both the cold-start share (app launched by an external share)
  /// and any share arriving later on the live EventChannel into
  /// [pendingSharedFileInfo], which replays its latest value to late
  /// subscribers. Must run from app start (not from the mailbox controller)
  /// so a share tapped before the user reaches the mailbox — e.g. while
  /// still on the login screen — isn't dropped: the live stream itself
  /// doesn't buffer events emitted before a listener attaches.
  void registerReceivingFileSharingStreamWhileAppClosed() {
    _mediaStreamSubscription ??= ReceiveSharingIntent.instance
      .getMediaStream()
      .listen(
        setPendingFileInfo,
        onError: (error) {
          logWarning('EmailReceiveManager::registerReceivingFileSharingStreamWhileAppClosed::getMediaStream: Exception = $error');
        },
      );

    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      // A share can land on the live stream above before getInitialMedia
      // resolves. getInitialMedia returns empty on a normal (non-share) launch,
      // so applying it unconditionally would overwrite that just-arrived share
      // with an empty list. Only apply the cold-start share when non-empty.
      if (value.isNotEmpty) {
        setPendingFileInfo(value);
      }
      ReceiveSharingIntent.instance.reset();
    }).catchError((error) {
      logWarning('EmailReceiveManager::registerReceivingFileSharingStreamWhileAppClosed::getInitialMedia: Exception = $error');
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