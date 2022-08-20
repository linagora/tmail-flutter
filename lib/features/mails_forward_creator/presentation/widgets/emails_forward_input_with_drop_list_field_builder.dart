
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/mails_forward_creator/presentation/widgets/emails_forward_input_decoration_builder.dart';

typedef OnSelectedSuggestionAction = Function(EmailAddress emailAddress);
typedef OnSuggestionCallbackAction = Function(String? pattern);
typedef OnSummitedCallbackAction = Function(String? pattern);


class EmailsForwardInputWithDropListFieldBuilder {

  final String hintText;
  final TextEditingController editingController;

  OnSelectedSuggestionAction? _onSelectedSuggestionAction;
  OnSuggestionCallbackAction? _onSuggestionCallbackAction;
  OnSummitedCallbackAction? _onSummitedCallbackAction;

  EmailsForwardInputWithDropListFieldBuilder(
    this.hintText,
    this.editingController,
  );

  void addOnSelectedSuggestionAction(OnSelectedSuggestionAction action) {
    _onSelectedSuggestionAction = action;
  }

  void addOnSuggestionCallbackAction(OnSuggestionCallbackAction action) {
    _onSuggestionCallbackAction = action;
  }

  void addOnSummitedCallbackAction(OnSummitedCallbackAction action) {
    _onSummitedCallbackAction = action;
  }

  Widget build() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      TypeAheadFormField<EmailAddress>(
        textFieldConfiguration: TextFieldConfiguration(
            controller: editingController,
            onSubmitted: (pattern) {
              if (_onSummitedCallbackAction != null) {
                _onSummitedCallbackAction!(pattern);
              }
            },
            textInputAction: TextInputAction.done,
            decoration: (EmailsForwardInputDecorationBuilder()
                ..setContentPadding(const EdgeInsets.symmetric(
                    vertical: BuildUtils.isWeb ? 16 : 12,
                    horizontal: 12))
                ..setHintText(hintText))
              .build()
        ),
        debounceDuration: const Duration(milliseconds: 500),
        suggestionsCallback: (pattern) async {
          if (_onSuggestionCallbackAction != null) {
            return _onSuggestionCallbackAction!(pattern);
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
          if (_onSelectedSuggestionAction != null) {
            _onSelectedSuggestionAction!(emailSelected);
          }
        },
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          borderRadius: BorderRadius.circular(14)
        ),
        noItemsFoundBuilder: (context) => const SizedBox(),
        hideOnEmpty: true,
        hideOnError: true,
        hideOnLoading: true,
      )
    ]);
  }
}