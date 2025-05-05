
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';

class CountOfEmailsWidget extends StatelessWidget {

  final String value;

  const CountOfEmailsWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: CommonTextStyle.defaultTextOverFlow,
      softWrap: CommonTextStyle.defaultSoftWrap,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.black,
      ),
    );
  }
}
