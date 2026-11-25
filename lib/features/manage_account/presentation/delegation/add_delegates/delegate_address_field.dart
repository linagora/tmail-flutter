import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_input_tag_item.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_suggestion_box_item.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/add_delegates_form.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

typedef DelegateSuggestionLoader = Future<List<EmailAddress>> Function(String query, {int? limit});
/// Returns false when the address is refused, so a typed address stays in the field to be fixed.
typedef OnPickDelegateAddress = bool Function(EmailAddress emailAddress);
typedef OnUnpickDelegate = void Function(DelegateCandidate candidate);
typedef OnDelegateAddressTyped = void Function(String text);

/// Contact autocomplete with one chip per picked address. Rejected chips are outlined in red.
class DelegateAddressField extends StatefulWidget {
  final List<DelegateCandidate> candidates;
  final DelegateSuggestionLoader loadSuggestions;
  final OnPickDelegateAddress onPick;
  final OnUnpickDelegate onUnpick;
  final OnDelegateAddressTyped onTyped;

  const DelegateAddressField({
    super.key,
    required this.candidates,
    required this.loadSuggestions,
    required this.onPick,
    required this.onUnpick,
    required this.onTyped,
  });

  @override
  State<DelegateAddressField> createState() => _DelegateAddressFieldState();
}

class _DelegateAddressFieldState extends State<DelegateAddressField> {
  final _imagePaths = Get.find<ImagePaths>();
  final _textController = TextEditingController();
  late final _focusNode = FocusNode()..addListener(_onFocusChanged);
  final _tagEditorKey = GlobalKey<TagsEditorState<SuggestionEmailAddress>>();
  int _focusedTagIndex = -1;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_reportTyped);
  }

  @override
  void dispose() {
    _textController.removeListener(_reportTyped);
    _textController.dispose();
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  // The tag editor reports focus gain only, so a focus loss must rebuild the outline here.
  void _onFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final candidates = widget.candidates;

    return InputDecorator(
      key: const ValueKey(UiKeys.addDelegatesAddressField),
      isFocused: _focusNode.hasFocus,
      decoration: InputDecoration(
        labelText: l10n.delegateEmailAddressLabel,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: ThemeUtils.textStyleBodyBody3(color: AppColor.steelGrayA540),
        floatingLabelStyle: ThemeUtils.textStyleBodyBody3(
          color: _focusNode.hasFocus ? AppColor.primaryMain : AppColor.steelGrayA540,
        ),
        contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 12, bottom: 8),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: AppColor.m3Neutral90),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: AppColor.m3Neutral90),
        ),
        // The app theme's primary is not the brand blue, so the focus colour is set here.
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: AppColor.primaryMain, width: 2),
        ),
      ),
      child: TagEditor<SuggestionEmailAddress>(
        key: _tagEditorKey,
        length: candidates.length,
        controller: _textController,
        focusNodeKeyboard: _focusNode,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        cursorColor: AppColor.primaryMain,
        tagSpacing: PlatformInfo.isWeb ? 8 : 4,
        minTextFieldWidth: 20,
        debounceDuration: const Duration(milliseconds: 150),
        autoScrollToInput: false,
        suggestionsBoxBackgroundColor: Colors.white,
        suggestionsBoxRadius: 16,
        suggestionsBoxMaxHeight: 300,
        suggestionPadding: const EdgeInsets.symmetric(vertical: 12),
        suggestionItemHeight: ComposerStyle.suggestionItemHeight,
        textStyle: ThemeUtils.textStyleBodyBody3(color: Colors.black),
        inputDecoration: InputDecoration(
          border: InputBorder.none,
          hintText: candidates.isEmpty ? l10n.delegateEmailAddressHint : null,
          hintStyle: ThemeUtils.textStyleBodyBody3(color: AppColor.steelGray400),
        ),
        onFocusTagAction: (index) => setState(() => _focusedTagIndex = index),
        onDeleteTagAction: (index) {
          if (index >= 0 && index < candidates.length) widget.onUnpick(candidates[index]);
        },
        onSelectOptionAction: (suggestion) => widget.onPick(suggestion.emailAddress),
        onSubmitted: _pickTyped,
        onTagChanged: (_) {},
        tagBuilder: (_, index) => ContactInputTagItem(
          candidates[index].emailAddress,
          isTagFocused: _focusedTagIndex == index,
          hasError: candidates[index].isRejected,
          deleteContactCallbackAction: (_) => widget.onUnpick(candidates[index]),
        ),
        findSuggestions: (query) => _findSuggestions(query, limit: AppConfig.defaultLimitAutocomplete),
        suggestionBuilder: (_, tagEditorState, suggestion, __, ___, ____, _____) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ContactSuggestionBoxItem(
            suggestion,
            _imagePaths,
            shapeBorder: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            selectedContactCallbackAction: (emailAddress) {
              widget.onPick(emailAddress);
              tagEditorState.closeSuggestionBox();
              tagEditorState.resetTextField();
            },
          ),
        ),
      ),
    );
  }

  void _reportTyped() => widget.onTyped(_textController.text);

  void _pickTyped(String value) {
    final address = value.trim();
    if (address.isEmpty) return;
    if (!widget.onPick(EmailAddress(null, address))) return;
    // Resetting through the editor also drops the pending debounced search of the typed text.
    _tagEditorKey.currentState?.resetTextField();
    _tagEditorKey.currentState?.closeSuggestionBox();
  }

  Future<List<SuggestionEmailAddress>> _findSuggestions(String query, {int? limit}) async {
    final word = query.trim();
    if (word.length < AppConfig.defaultMinInputLengthAutocomplete) return [];
    final picked = widget.candidates.map((candidate) => candidate.username.toLowerCase()).toSet();
    final contacts = await widget.loadSuggestions(word, limit: limit);
    return contacts
        .map((contact) => picked.contains(contact.emailAddress.toLowerCase())
            ? SuggestionEmailAddress(contact, state: SuggestionEmailState.duplicated)
            : SuggestionEmailAddress(contact))
        .toSet()
        .toList();
  }
}
