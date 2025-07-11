import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class IdentityCreatorFormTitleWidget extends StatelessWidget {
  final String title;

  const IdentityCreatorFormTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 32,
          end: 32,
          top: 24,
          bottom: 12,
        ),
        child: Text(
          title,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: ThemeUtils.textStyleM3HeadlineSmall,
        ),
      ),
    );
  }
}
