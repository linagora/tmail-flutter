
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/text/type_ahead_form_field_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_decoration_builder.dart';

typedef OnSelectedSuggestionAction = Function(EmailAddress? emailAddress);
typedef OnSuggestionCallbackAction = Function(String? pattern);
typedef OnChangeInputSuggestionAction = Function(String? pattern);

class IdentityInputWithDropListFieldBuilder extends StatelessWidget {

  final String _label;
  final String? _error;
  final TextEditingController? editingController;
  final FocusNode? focusNode;
  final OnSelectedSuggestionAction? onSelectedSuggestionAction;
  final OnSuggestionCallbackAction? onSuggestionCallbackAction;
  final OnChangeInputSuggestionAction? onChangeInputSuggestionAction;

  const IdentityInputWithDropListFieldBuilder(
    this._label,
    this._error,
    this.editingController, {
    super.key,
    this.focusNode,
    this.onSelectedSuggestionAction,
    this.onSuggestionCallbackAction,
    this.onChangeInputSuggestionAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        _label,
        style: ThemeUtils.defaultTextStyleInterFont.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColor.colorContentEmail)),
      const SizedBox(height: 8),
      TypeAheadFormFieldBuilder<EmailAddress>(
        focusNode: focusNode,
        controller: editingController,
        textInputAction: TextInputAction.done,
        decoration: (IdentityInputDecorationBuilder()
          ..setContentPadding(EdgeInsets.symmetric(
              vertical: PlatformInfo.isWeb ? 16 : 12,
              horizontal: 12))
          ..setErrorText(_error))
        .build(),
        debounceDuration: const Duration(milliseconds: 500),
        suggestionsCallback: (pattern) async {
          if (onChangeInputSuggestionAction != null) {
            onChangeInputSuggestionAction!(pattern);
          }
          if (onSuggestionCallbackAction != null) {
            return onSuggestionCallbackAction!(pattern);
          } else {
            return [];
          }
        },
        itemBuilder: (BuildContext context, emailAddress) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              emailAddress.email ?? '',
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black)));
        },
        onSuggestionSelected: (emailSelected) {
          if (onSelectedSuggestionAction != null) {
            onSelectedSuggestionAction!(emailSelected);
          }
        },
        noItemsFoundBuilder: (context) => const SizedBox(),
        hideOnEmpty: true,
        hideOnError: true,
        hideOnLoading: true,
      )
    ]);
  }
}