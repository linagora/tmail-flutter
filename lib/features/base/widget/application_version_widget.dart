import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/application_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApplicationVersionWidget extends StatefulWidget {

  final EdgeInsetsGeometry? padding;
  final String? title;
  final TextStyle? textStyle;

  const ApplicationVersionWidget({
    super.key,
    this.title,
    this.textStyle,
    this.padding,
  });

  @override
  State<ApplicationVersionWidget> createState() => _ApplicationVersionWidgetState();
}

class _ApplicationVersionWidgetState extends State<ApplicationVersionWidget> {

  final ApplicationManager _applicationManager = Get.find<ApplicationManager>();
  Future<String>? _versionStream;

  @override
  void initState() {
    super.initState();
    _versionStream = _applicationManager.getVersion();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _versionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: widget.padding ?? const EdgeInsets.only(top: 8),
            child: Text(
              '${widget.title ?? 'v.'}${snapshot.data}',
              textAlign: TextAlign.center,
              style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColor.steelGray400,
              ),
            ),
          );
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
