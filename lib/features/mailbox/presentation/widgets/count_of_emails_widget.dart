
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/count_of_emails_styles.dart';

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
      style: const TextStyle(
        fontSize: CountOfEmailsStyles.textSize,
        color: CountOfEmailsStyles.textColor,
        fontWeight: CountOfEmailsStyles.textFontWeight
      ),
    );
  }
}
