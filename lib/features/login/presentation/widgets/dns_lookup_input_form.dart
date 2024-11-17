
import 'package:core/presentation/views/quick_search/quick_search_action_define.dart';
import 'package:core/presentation/views/text/type_ahead_form_field_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/base/widget/recent_item_tile_widget.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_input_decoration_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DNSLookupInputForm extends StatelessWidget {

  final TextEditingController textEditingController;
  final ValueChanged<String> onTextChange;
  final ValueChanged<String> onTextSubmitted;
  final SuggestionsCallback<RecentLoginUsername> suggestionsCallback;
  final SuggestionSelectionCallback<RecentLoginUsername> onSuggestionSelected;

  const DNSLookupInputForm({
    super.key,
    required this.textEditingController,
    required this.onTextChange,
    required this.onTextSubmitted,
    required this.suggestionsCallback,
    required this.onSuggestionSelected
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16, start: 24, end: 24),
      child: TypeAheadFormFieldBuilder<RecentLoginUsername>(
        controller: textEditingController,
        onTextChange: onTextChange,
        onTextSubmitted: onTextSubmitted,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        autofillHints: const [AutofillHints.email],
        keyboardType: TextInputType.emailAddress,
        decoration: (LoginInputDecorationBuilder()
          ..setLabelText(AppLocalizations.of(context).email)
          ..setHintText(AppLocalizations.of(context).email)
        ).build(),
        debounceDuration: const Duration(milliseconds: 300),
        suggestionsCallback: suggestionsCallback,
        itemBuilder: (_, loginUsername) => RecentItemTileWidget(loginUsername),
        onSuggestionSelected: onSuggestionSelected,
        noItemsFoundBuilder: (context) => const SizedBox(),
        hideOnEmpty: true,
        hideOnError: true,
        hideOnLoading: true,
      ),
    );
  }
}