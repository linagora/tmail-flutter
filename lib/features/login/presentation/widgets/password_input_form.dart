
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_text_input_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class PasswordInputForm extends StatelessWidget {
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final ValueChanged<String> onTextChange;
  final ValueChanged<String> onTextSubmitted;

  const PasswordInputForm({
    super.key,
    required this.textEditingController,
    required this.focusNode,
    required this.onTextChange,
    required this.onTextSubmitted
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16, start: 24, end: 24),
      child: LoginTextInputBuilder(
        controller: textEditingController,
        autofillHints: const [AutofillHints.password],
        textInputAction: TextInputAction.done,
        hintText: AppLocalizations.of(context).password,
        focusNode: focusNode,
        onTextChange: onTextChange,
        onSubmitted: onTextSubmitted,
      ),
    );
  }
}
