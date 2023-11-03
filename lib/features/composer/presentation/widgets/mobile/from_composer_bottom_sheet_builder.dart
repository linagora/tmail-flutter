import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile/from_composer_bottom_sheet_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnChangeIdentity = void Function(Identity? identity);
typedef OnTextSearchChanged = void Function(String text);

class FromComposerBottomSheetBuilder {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final List<Identity> _identities;
  final ScrollController _scrollController;
  final TextEditingController _textInputSearchController;
  
  late double _statusBarHeight;

  FocusNode? _textInputSearchFocusNode;
  OnChangeIdentity? _onChangeIdentity;
  VoidCallback? _onClose;
  OnTextSearchChanged? _onTextSearchChanged;

  FromComposerBottomSheetBuilder(
    this._context,
    this._imagePaths,
    this._identities,
    this._scrollController,
    this._textInputSearchController,
  ) {
    _statusBarHeight = Get.statusBarHeight / MediaQuery.of(_context).devicePixelRatio;
  }

  void onChangeIdentityAction(OnChangeIdentity onChangeIdentity) {
    _onChangeIdentity = onChangeIdentity;
  }

  void onCloseAction(VoidCallback onClose) {
    _onClose = onClose;
  }

  void onTextSearchChangedAction(OnTextSearchChanged onTextSearchChanged) {
    _onTextSearchChanged = onTextSearchChanged;
  }

  Future build() {
    return showModalBottomSheet(
      context: _context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      barrierColor: FromComposerBottomSheetStyle.barrierColor,
      builder: (context) {
        return Obx(() => PointerInterceptor(
          child: SafeArea(
            top: true,
            bottom: false,
            left: false,
            right: false,
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Padding(
                padding: EdgeInsets.only(top: _statusBarHeight),
                child: ClipRRect(
                  borderRadius: FromComposerBottomSheetStyle.backgroundBorderRadius,
                  child: Scaffold(
                    resizeToAvoidBottomInset: true,
                    appBar: AppBar(
                      leading: const SizedBox.shrink(),
                      title: Text(AppLocalizations.of(context).yourIdentities),
                      titleTextStyle: FromComposerBottomSheetStyle.appBarTitleTextStyle,
                      centerTitle: true,
                      actions: [
                        GestureDetector(
                          child: Padding(
                            padding: FromComposerBottomSheetStyle.closeButtonPadding,
                            child: SvgPicture.asset(_imagePaths.icCircleClose),
                          ),
                          onTapDown: (_) {
                            _onClose?.call();
                          },
                        )
                      ],
                    ),
                    body: Padding(
                      padding: FromComposerBottomSheetStyle.bodyPadding,
                      child: Column(
                        children: [
                          Container(
                            decoration: FromComposerBottomSheetStyle.searchBarDecoration,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: FromComposerBottomSheetStyle.space),
                                buildIconWeb(
                                  icon: SvgPicture.asset(
                                    _imagePaths.icSearchBar,
                                    fit: BoxFit.fill,
                                    colorFilter: FromComposerBottomSheetStyle.searchIconColor.asFilter(),
                                  ),
                                  iconPadding: EdgeInsets.zero,
                                  iconSize: FromComposerBottomSheetStyle.searchIconSize,
                                ),
                                Expanded(
                                  child: TextFieldBuilder(
                                    controller: _textInputSearchController,
                                    focusNode: _textInputSearchFocusNode,
                                    onTextChange: _onTextSearchChanged,
                                    textInputAction: TextInputAction.search,
                                    maxLines: 1,
                                    textDirection: DirectionUtils.getDirectionByLanguage(context),
                                    textStyle: FromComposerBottomSheetStyle.searchBarTextStyle,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      contentPadding: FromComposerBottomSheetStyle.searchTextInputPadding,
                                      hintText: AppLocalizations.of(context).searchForIdentities,
                                      hintStyle: FromComposerBottomSheetStyle.searchHintTextStyle,
                                      border: InputBorder.none
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: FromComposerBottomSheetStyle.searchBarBottomSpace),
                          Expanded(
                            child: RawScrollbar(
                              trackColor: AppColor.colorScrollbarTrackColor,
                              thumbColor: AppColor.colorScrollbarThumbColor,
                              radius: FromComposerBottomSheetStyle.radius,
                              trackRadius: FromComposerBottomSheetStyle.radius,
                              thickness: FromComposerBottomSheetStyle.scrollbarThickness,
                              thumbVisibility: true,
                              trackVisibility: true,
                              controller: _scrollController,
                              trackBorderColor: Colors.transparent,
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                child: ListView.builder(
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: _identities.length,
                                  itemBuilder: ((context, index) {
                                    final Identity identity = _identities[index];
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: FromComposerBottomSheetStyle.borderRadius,
                                        onTap: () => _onChangeIdentity?.call(identity),
                                        child: Padding(
                                          padding: FromComposerBottomSheetStyle.searchTextInputPadding,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: FromComposerBottomSheetStyle.identityItemSize,
                                                height: FromComposerBottomSheetStyle.identityItemSize,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColor.avatarColor,
                                                  border: Border.all(
                                                    color: AppColor.colorShadowBgContentEmail,
                                                    width: FromComposerBottomSheetStyle.identityItemBorderWidth
                                                  )
                                                ),
                                                child: Text(
                                                  identity.name!.isNotEmpty
                                                    ? identity.name!.firstLetterToUpperCase
                                                    : identity.email!.firstLetterToUpperCase,
                                                  style: FromComposerBottomSheetStyle.searchBarTextStyle,
                                                ),
                                              ),
                                              const SizedBox(width: FromComposerBottomSheetStyle.identityItemSpace),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    if (identity.name!.isNotEmpty)
                                                      Text(
                                                        identity.name!,
                                                        maxLines: 1,
                                                        softWrap: CommonTextStyle.defaultSoftWrap,
                                                        overflow: CommonTextStyle.defaultTextOverFlow,
                                                        style: FromComposerBottomSheetStyle.identityItemTitleTextStyle,
                                                      ),
                                                    if (identity.email!.isNotEmpty)
                                                      Text(
                                                        identity.email!,
                                                        maxLines: 1,
                                                        softWrap: CommonTextStyle.defaultSoftWrap,
                                                        overflow: CommonTextStyle.defaultTextOverFlow,
                                                        style: FromComposerBottomSheetStyle.identityItemSubTitleTextStyle,
                                                      )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          )
        ));
      },
    );
  }
}