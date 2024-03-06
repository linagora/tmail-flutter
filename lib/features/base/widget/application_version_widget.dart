import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/application_manager.dart';
import 'package:flutter/material.dart';

class ApplicationVersionWidget extends StatelessWidget {

  final ApplicationManager applicationManager;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final TextStyle? textStyle;

  const ApplicationVersionWidget({
    super.key,
    required this.applicationManager,
    this.title,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: applicationManager.getVersion(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: padding ?? const EdgeInsets.only(top: 6),
            child: Text(
              '${title ?? 'v.'}${snapshot.data}',
              textAlign: TextAlign.center,
              style: textStyle ?? Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 13,
                color: AppColor.colorContentEmail,
                fontWeight: FontWeight.w500
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }
}
