import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_search_filter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TextFieldAutoCompleteEmailAddress extends StatefulWidget {
  const TextFieldAutoCompleteEmailAddress({
    Key? key,
    required this.advancedSearchFilterField,
    required this.listTagSelected,
    required this.initialTags,
    required this.optionsBuilder,
  }) : super(key: key);
  final AdvancedSearchFilterField advancedSearchFilterField;
  final List<String> listTagSelected;
  final List<String> initialTags;
  final Future<List<EmailAddress>> Function(String) optionsBuilder;

  @override
  State<TextFieldAutoCompleteEmailAddress> createState() =>
      _TextFieldAutoCompleteEmailAddressState();
}

class _TextFieldAutoCompleteEmailAddressState
    extends State<TextFieldAutoCompleteEmailAddress> {
  final double _distanceToField = 380;
  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  late TextfieldTagsController _controller;

  @override
  void initState() {
    _controller = TextfieldTagsController();
    _controller.addListener(() {
      if(_controller.hasTags){
        widget.listTagSelected.addAll(_controller.getTags!);
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Autocomplete<EmailAddress>(
      optionsViewBuilder: (context, onSelected, options) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxHeight: 200, maxWidth: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final dynamic option = options.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        onSelected(option);
                      },
                      child: _buildSuggestionItem(context, option),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        return widget.optionsBuilder.call(textEditingValue.text);
      },
      onSelected: (EmailAddress selectedTag) {
        _controller.addTag = selectedTag.asString();
      },
      fieldViewBuilder: (context, ttec, tfn, onFieldSubmitted) {
        return TextFieldTags(
          initialTags: widget.initialTags,
          textEditingController: ttec,
          focusNode: tfn,
          textfieldTagsController: _controller,
          textSeparators: const [' ', ','],
          letterCase: LetterCase.normal,
          validator: (String tag) {
            if (_controller.getTags!.contains(tag)) {
              return AppLocalizations.of(context).messageDuplicateTagFilterMail;
            }
            return null;
          },
          inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
            return ((context, sc, tags, onTagDelete) {
              return TextField(
                controller: tec,
                focusNode: fn,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColor.loginTextFieldBackgroundColor,
                  contentPadding: const EdgeInsets.only(
                    right: 8,
                    left: 12,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: AppColor.colorInputBorderCreateMailbox,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  hintText:
                      widget.advancedSearchFilterField.getHintText(context),
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColor.colorHintSearchBar,
                  ),
                  prefixIconConstraints:
                      BoxConstraints(maxWidth: _distanceToField * 0.74),
                  prefixIcon: tags.isNotEmpty
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          controller: sc,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              children: tags.map((String tag) {
                            return _buildTagItem(context, tag, onTagDelete);
                          }).toList()),
                        )
                      : null,
                ),
                onChanged: onChanged,
                onSubmitted: (tag){
                  onSubmitted?.call(tag);
                },
              );
            });
          },
        );
      },
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    EmailAddress emailAddress,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.avatarColor,
                border: Border.all(
                    color: AppColor.colorShadowBgContentEmail, width: 1.0)),
            child: Text(
                emailAddress.asString().isNotEmpty
                    ? emailAddress.asString()[0].toUpperCase()
                    : '',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600))),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emailAddress.asString(),
                maxLines: 1,
                overflow: kIsWeb ? null : TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal)),
            if (emailAddress.displayName.isNotEmpty &&
                emailAddress.emailAddress.isNotEmpty)
              Text(emailAddress.emailAddress,
                  maxLines: 1,
                  overflow: kIsWeb ? null : TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColor.colorHintSearchBar,
                      fontSize: 13,
                      fontWeight: FontWeight.normal))
          ],
        )
      ],
    );
  }

  Widget _buildTagItem(
    BuildContext context,
    String tag,
    Function(String tag) onTagDelete,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        color: AppColor.colorBackgroundTagFilter.withOpacity(0.08),
      ),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColor.mapGradientColor[_generateIndex(tag)],
                  ),
                  border: Border.all(
                      color: AppColor.colorShadowBgContentEmail, width: 0.21)),
              child: Text(tag[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.57,
                      fontWeight: FontWeight.w600))),
          const SizedBox(width: 4),
          Text(tag,
              maxLines: 1,
              overflow: kIsWeb ? null : TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.normal)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: (){
              onTagDelete.call(tag);
              widget.listTagSelected.remove(tag);
            },
            child: SvgPicture.asset(
              _imagePaths.icClose,
              width: 28,
              height: 28,
              fit: BoxFit.fill,
            ),
          )
        ],
      ),
    );
  }

  int _generateIndex(String tag) {
    if (tag.isNotEmpty) {
      final codeUnits = tag.codeUnits;
      if (codeUnits.isNotEmpty) {
        final sumCodeUnits = codeUnits.sum;
        final index = sumCodeUnits % AppColor.mapGradientColor.length;
        return index;
      }
    }
    return 0;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
