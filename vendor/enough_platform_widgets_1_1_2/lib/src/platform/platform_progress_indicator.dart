import 'package:cupertino_progress_bar/cupertino_progress_bar.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Uses a `CircularProgressIndicator` on material and a `CupertinoActivityIndicator` - or the 'CupertinoProgressBar' from the `cupertino_progress_bar` package when the given value is not null - on cupertino
class PlatformProgressIndicator extends StatelessWidget {
  /// If non-null, the value of this progress indicator.
  ///
  /// A value of 0.0 means no progress and 1.0 means that progress is complete.
  ///
  /// If null, this progress indicator is indeterminate, which means the
  /// indicator displays a predetermined animation that does not indicate how
  /// much actual progress is being made.
  final double? value;

  /// Creates a new progress indicator with the optional [value].
  const PlatformProgressIndicator({Key? key, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final v = value;
    return PlatformWidget(
        material: (context, platform) => CircularProgressIndicator(value: v),
        cupertino: (context, platform) => (v == null)
            ? CupertinoActivityIndicator()
            : CupertinoProgressBar(value: v));
  }
}
