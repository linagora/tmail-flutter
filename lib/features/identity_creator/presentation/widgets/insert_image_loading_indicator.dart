
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class InsertImageLoadingIndicator extends StatelessWidget {

  final bool isInserting;

  const InsertImageLoadingIndicator({
    super.key,
    required this.isInserting
  });

  @override
  Widget build(BuildContext context) {
    if (isInserting) {
     return const Align(
       alignment: Alignment.center,
       child: CircularProgressIndicator(
         color: AppColor.primaryColor
       )
     );
    } else {
      return const SizedBox.shrink();
    }
  }
}
