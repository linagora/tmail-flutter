import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

class AiScribeMenuText extends StatelessWidget {
  final String text;

  const AiScribeMenuText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Text(
        text,
        style: AIScribeTextStyles.menuItem,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}