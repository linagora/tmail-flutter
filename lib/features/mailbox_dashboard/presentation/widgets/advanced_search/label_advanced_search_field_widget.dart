import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class LabelAdvancedSearchFieldWidget extends StatelessWidget {
  final String name;

  const LabelAdvancedSearchFieldWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
    );
  }
}
