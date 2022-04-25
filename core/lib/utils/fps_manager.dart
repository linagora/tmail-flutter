import 'dart:collection';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/scheduler.dart';

/// FpsManager callback.
typedef FpsCallback = void Function(FpsInfo fpsInfo);

class FpsManager {

  FpsManager._();

  factory FpsManager() => _instance ??= FpsManager._();

  static FpsManager? _instance;

  /// Threshold time consuming per frame
  /// 1000/60hz ≈ 16.6ms  1000/120hz ≈ 8.3ms
  Duration _thresholdPerFrame = Duration(microseconds: Duration.microsecondsPerSecond ~/ 60);

  /// Refresh rate, default 60
  double _refreshRate = 60;

  /// Set refresh rate
  set refreshRate(double rate) {
    if (rate != _refreshRate && rate >= 60) {
      _refreshRate = rate;
      _thresholdPerFrame = Duration(microseconds: Duration.microsecondsPerSecond ~/ _refreshRate);
    }
  }

  bool _started = false;
  List<FpsCallback> _fpsCallbacks = [];

  /// Temporarily save 120 frames
  static const int _queue_capacity = 120;
  final ListQueue framesQueue = ListQueue<FrameTiming>(_queue_capacity);

  void addFpsCallback(FpsCallback callback) {
    _fpsCallbacks.add(callback);
  }

  void removeFpsCallback(FpsCallback callback) {
    assert(_fpsCallbacks.contains(callback));
    _fpsCallbacks.remove(callback);
  }

  void start() async {
    if (BuildUtils.isDebugMode || BuildUtils.isProfileMode) {
      if (!_started) {
        SchedulerBinding.instance?.addTimingsCallback(_onTimingsCallback);
        _started = true;
      }
    }
  }

  void stop() {
    if (BuildUtils.isDebugMode || BuildUtils.isProfileMode) {
      if (_started) {
        SchedulerBinding.instance?.removeTimingsCallback(_onTimingsCallback);
        _started = false;
      }
    }
  }

  _onTimingsCallback(List<FrameTiming> timings) async {
    if (_fpsCallbacks.isNotEmpty) {
      for (FrameTiming timing in timings) {
        framesQueue.addFirst(timing);
      }
      while (framesQueue.length > _queue_capacity) {
        framesQueue.removeLast();
      }

      List<FrameTiming> drawFrames = [];
      for (FrameTiming timing in framesQueue) {
        if (drawFrames.isEmpty) {
          drawFrames.add(timing);
        } else {
          int lastStart =
          drawFrames.last.timestampInMicroseconds(FramePhase.vsyncStart);
          int interval = lastStart -
              timing.timestampInMicroseconds(FramePhase.rasterFinish);
          if (interval > (_thresholdPerFrame.inMicroseconds * 2)) {
            // maybe in different set
            break;
          }
          drawFrames.add(timing);
        }
      }
      framesQueue.clear();

      // compute total frames count.
      int totalCount = drawFrames.map((frame) {
        // If droppedCount > 0,
        int droppedCount = frame.totalSpan.inMicroseconds ~/ _thresholdPerFrame.inMicroseconds;
        return droppedCount + 1;
      }).fold(0, (a, b) => a + b);

      int drawFramesCount = drawFrames.length;
      int droppedCount = totalCount - drawFramesCount;
      double fps = drawFramesCount / totalCount * _refreshRate;
      FpsInfo fpsInfo = FpsInfo(fps, totalCount, droppedCount, drawFramesCount);
      _fpsCallbacks.forEach((callBack) {
        callBack(fpsInfo);
      });
    }
  }
}

class FpsInfo {
  final double fps;
  final int totalFramesCount;
  final int droppedFramesCount;
  final int drawFramesCount;

  FpsInfo(
    this.fps,
    this.totalFramesCount,
    this.droppedFramesCount,
    this.drawFramesCount
  );

  @override
  String toString() {
    return 'FpsInfo{'
        'fps: $fps, '
        'totalFramesCount: $totalFramesCount, '
        'droppedFramesCount: $droppedFramesCount, '
        'drawFramesCount: $drawFramesCount}';
  }
}