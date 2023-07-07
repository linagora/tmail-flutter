import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/custom_tf_tag_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TextFieldAutoCompleteEmailAddress extends StatefulWidget {
 const TextFieldAutoCompleteEmailAddress({
    Key? key,
    required this.advancedSearchFilterField,
    required this.initialTags,
    required this.optionsBuilder,
    required this.onChange,
    required this.onDeleteTag,
    required this.onAddTag,
    this.currentFocusNode,
    this.nextFocusNode,
  }) : super(key: key);
  final AdvancedSearchFilterField advancedSearchFilterField;
  final Set<String> initialTags;
  final Future<List<EmailAddress>> Function(String) optionsBuilder;
  final Function(String) onChange;
  final Function(String) onDeleteTag;
  final Function(String) onAddTag;
  final FocusNode? currentFocusNode;
  final FocusNode? nextFocusNode;

  @override
  State<TextFieldAutoCompleteEmailAddress> createState() =>
      _TextFieldAutoCompleteEmailAddressState();
}

class _TextFieldAutoCompleteEmailAddressState
    extends State<TextFieldAutoCompleteEmailAddress> {
  final double _distanceToField = 380;
  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  late CustomController _controller;

  @override
  void initState() {
    _controller = CustomController();
    _controller.setActionRemoveTag((tag) {
      widget.onDeleteTag.call(tag);
    });
    _controller.setActionAddTag((tag) {
      widget.onAddTag.call(tag);
    });
    _controller.setActionChangeText((tag) {
      widget.onChange.call(tag);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<EmailAddress>(
      optionsViewBuilder: (context, onSelected, listEmailAddress) {
        return Container(
          margin: const EdgeInsets.only(
            top: PlatformInfo.isWeb ? 5 : 8,
            bottom: 16),
          height: _getHeightSuggestionBox(listEmailAddress.length, 65),
          width: maxWidthSuggestionBox,
          alignment: Alignment.topLeft,
          child: Card(
            elevation: 20,
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                alignment: Alignment.topCenter,
                height: _getHeightSuggestionBox(listEmailAddress.length, 65),
                width: maxWidthSuggestionBox,
                color: Colors.white,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemExtent: 65,
                  itemCount: listEmailAddress.length,
                  itemBuilder: (BuildContext context, int index) {
                    final emailAddress = listEmailAddress.elementAt(index);
                    return InkWell(
                      onTap: () {_controller.onSubmitted(emailAddress.emailAddress);},
                      child: _buildSuggestionItem(context, emailAddress),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<EmailAddress>.empty();
        }
        return widget.optionsBuilder.call(textEditingValue.text.toLowerCase());
      },
      onSelected: (EmailAddress selectedTag) {
        _controller.addTag = selectedTag.emailAddress;
      },
      fieldViewBuilder: (context, ttec, tfn, onFieldSubmitted) {
        return TextFieldTags(
          initialTags: widget.initialTags.toList(),
          textEditingController: ttec,
          focusNode: tfn,
          textfieldTagsController: _controller,
          textSeparators: const ['\n', ','],
          letterCase: LetterCase.normal,
          validator: (String tag) {
            if (_controller.getTags!.contains(tag)) {
              return AppLocalizations.of(context).messageDuplicateTagFilterMail;
            }
            return null;
          },
          inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
            return ((context, sc, tags, onTagDelete) {
              return RawKeyboardListener(
                focusNode: widget.currentFocusNode ?? FocusNode(),
                onKey: (event) {
                  log('_TextFieldAutoCompleteEmailAddressState::inputfieldBuilder(): Event runtimeType is ${event.runtimeType}');
                  if (event is RawKeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.tab) {
                    log('_TextFieldAutoCompleteEmailAddressState::inputfieldBuilder(): PRESS TAB');
                    widget.nextFocusNode?.requestFocus();
                  }
                },
                child: TextFieldBuilder(
                  controller: tec,
                  focusNode: fn,
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.only(
                      right: 8,
                      left: 12,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      borderSide: BorderSide(
                        width: 1,
                        color: AppColor.colorInputBorderCreateMailbox,
                      ),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      borderSide: BorderSide(
                        width: 1,
                        color: AppColor.colorInputBorderCreateMailbox,
                      ),
                    ),
                    hintText: widget.advancedSearchFilterField.getHintText(context),
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: AppColor.colorHintSearchBar,
                    ),
                    prefixIconConstraints: BoxConstraints(maxWidth: _distanceToField * 0.74),
                    prefixIcon: tags.isNotEmpty ? SingleChildScrollView(
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
                  onTextChange: (value) {
                    if (value.trim().isNotEmpty) {
                      onChanged?.call(value);
                    }
                  },
                  onTextSubmitted: (tag) {
                    if (tag.trim().isNotEmpty) {
                      onSubmitted?.call(tag);
                      fn.requestFocus();
                    } else {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.avatarColor,
                border: Border.all(
                    color: AppColor.colorShadowBgContentEmail,
                    width: 1.0)),
            child: Text(
                emailAddress.asString().isNotEmpty
                    ? emailAddress.asString()[0].toUpperCase()
                    : '',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600))),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  emailAddress.asString(),
                  maxLines: 1,
                  softWrap: CommonTextStyle.defaultSoftWrap,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16, fontWeight:
                  FontWeight.normal)),
              if (emailAddress.displayName.isNotEmpty &&
                  emailAddress.emailAddress.isNotEmpty)
                Text(
                    emailAddress.emailAddress,
                    maxLines: 1,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    style: const TextStyle(
                        color: AppColor.colorHintSearchBar,
                        fontSize: 13,
                        fontWeight: FontWeight.normal))
          ]),
        )),
      ]),
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
          InkWell(
            onTap: () => onTagDelete.call(tag),
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

  double _getHeightSuggestionBox(int countItem, double heightItem) {
    final maxHeightList = countItem * heightItem;

    if (PlatformInfo.isWeb) {
      return maxHeightList > 250 ? 250 : maxHeightList;
    } else {
      if (_responsiveUtils.isLandscapeMobile(context)) {
        return maxHeightList > 180 ? 180 : maxHeightList;
      } else {
        return maxHeightList > 250 ? 250 : maxHeightList;
      }
    }
  }

  double get maxWidthSuggestionBox {
    if (PlatformInfo.isWeb) {
      if (_responsiveUtils.isTabletLarge(context)) {
        return 300;
      } else {
        return 400;
      }
    } else {
      if (_responsiveUtils.isLandscapeMobile(context)) {
        return 400;
      } else if (_responsiveUtils.isLandscapeTablet(context) ||
          _responsiveUtils.isTabletLarge(context) ||
          _responsiveUtils.isDesktop(context)) {
        return 300;
      } else {
        return 350;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
