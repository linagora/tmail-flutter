
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_decoration_builder.dart';

typedef OnSelectedSuggestionAction = Function(EmailAddress? emailAddress);
typedef OnSuggestionCallbackAction = Function(String? pattern);
typedef OnChangeInputSuggestionAction = Function(String? pattern);

class IdentityInputWithDropListFieldBuilder {

  final String _label;
  final String? _error;
  final TextEditingController editingController;

  OnSelectedSuggestionAction? _onSelectedSuggestionAction;
  OnSuggestionCallbackAction? _onSuggestionCallbackAction;
  OnChangeInputSuggestionAction? _onChangeInputSuggestionAction;

  IdentityInputWithDropListFieldBuilder(
    this._label,
    this._error,
    this.editingController,
  );

  void addOnSelectedSuggestionAction(OnSelectedSuggestionAction action) {
    _onSelectedSuggestionAction = action;
  }

  void addOnSuggestionCallbackAction(OnSuggestionCallbackAction action) {
    _onSuggestionCallbackAction = action;
  }

  void addOnChangeInputSuggestionAction(OnChangeInputSuggestionAction action) {
    _onChangeInputSuggestionAction = action;
  }

  Widget build() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_label, style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColor.colorContentEmail)),
      const SizedBox(height: 8),
      TypeAheadFormField<EmailAddress>(
        textFieldConfiguration: TextFieldConfiguration(
            controller: editingController,
            textInputAction: TextInputAction.done,
            decoration: (IdentityInputDecorationBuilder()
                ..setContentPadding(const EdgeInsets.symmetric(
                    vertical: BuildUtils.isWeb ? 16 : 12,
                    horizontal: 12))
                ..setErrorText(_error))
              .build()
        ),
        debounceDuration: const Duration(milliseconds: 500),
        suggestionsCallback: (pattern) async {
          if (_onChangeInputSuggestionAction != null) {
            _onChangeInputSuggestionAction!(pattern);
          }
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