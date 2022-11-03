
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/recipient_input_decoration_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSelectedSuggestionAction = Function(EmailAddress emailAddress);
typedef OnSuggestionCallbackAction = Function(String pattern);
typedef OnSummitedCallbackAction = Function(String pattern);
typedef OnRecipientInputTextChange = Function(String pattern);

class RecipientInputFieldBuilder extends StatelessWidget {

  final TextEditingController? editingController;
  final OnSelectedSuggestionAction? onSelectedSuggestionAction;
  final OnSuggestionCallbackAction? onSuggestionCallbackAction;
  final OnSummitedCallbackAction? onSummitedCallbackAction;
  final OnRecipientInputTextChange? onRecipientInputTextChange;
  final String? errorText;

  const RecipientInputFieldBuilder({
    Key? key,
    this.editingController,
    this.onSelectedSuggestionAction,
    this.onSuggestionCallbackAction,
    this.onSummitedCallbackAction,
    this.onRecipientInputTextChange,
    this.errorText
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField<EmailAddress>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: editingController,
        onSubmitted: (pattern) {
          if (onSummitedCallbackAction != null) {
            onSummitedCallbackAction!(pattern);
          }
        },
        onChanged: onRecipientInputTextChange,
        textInputAction: TextInputAction.done,
        decoration: (RecipientInputDecorationBuilder()
          ..setHintText(AppLocalizations.of(context).recipientsLabel)
          ..setErrorText(errorText)
        ).build()
      ),
      debounceDuration: const Duration(milliseconds: 500),
      suggestionsCallback: (pattern) async {
        if (onSuggestionCallbackAction != null) {
          return onSuggestionCallbackAction!(pattern);
        } else {
          return [];
        }
      },
      itemBuilder: (BuildContext context, emailAddress) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(emailAddress.email ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black)),
        );
      },
      onSuggestionSelected: (emailSelected) {
        if (onSelectedSuggestionAction != null) {
          onSelectedSuggestionAction!(emailSelected);
        }
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        borderRadius: BorderRadius.circular(14)
      ),
      noItemsFoundBuilder: (context) => const SizedBox(),
      hideOnEmpty: true,
      hideOnError: true,
      hideOnLoading: true,
    );
  }
}