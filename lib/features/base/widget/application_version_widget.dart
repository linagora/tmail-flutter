import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/application_manager.dart';
import 'package:flutter/material.dart';

typedef ApplicationVersionBuilder = Widget Function(
  BuildContext context,
  String version,
);

class ApplicationVersionWidget extends StatefulWidget {

  final EdgeInsetsGeometry? padding;
  final String? title;
  final TextStyle? textStyle;
  /// Custom renderer for the complete version label.
  ///
  /// When supplied, this takes precedence over [padding] and [textStyle].
  final ApplicationVersionBuilder? builder;

  const ApplicationVersionWidget({
    super.key,
    this.title,
    this.textStyle,
    this.padding,
    this.builder,
  });

  @override
  State<ApplicationVersionWidget> createState() => _ApplicationVersionWidgetState();
}

class _ApplicationVersionWidgetState extends State<ApplicationVersionWidget> {

  Future<String>? _versionStream;

  @override
  void initState() {
    super.initState();
    _versionStream = ApplicationManager().getAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _versionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final builder = widget.builder;
          if (builder != null) {
            return builder(context, '${widget.title ?? 'v.'}${snapshot.data}');
          }

          final versionLabel = Text(
            '${widget.title ?? 'v.'}${snapshot.data}',
            textAlign: TextAlign.center,
            style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColor.steelGray400,
            ),
          );

          if (widget.padding != null) {
            return Padding(
              padding: widget.padding!,
              child: versionLabel,
            );
          } else {
            return versionLabel;
          }
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }

  @override
  void dispose() {
    _versionStream = null;
    super.dispose();
  }
}
