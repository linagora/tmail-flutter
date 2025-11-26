import 'dart:math' as math;

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/color/colors_map_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:labels/extensions/list_label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_close_button_widget.dart';
import 'package:tmail_ui_user/features/base/widget/label_input_field_builder.dart';
import 'package:tmail_ui_user/features/base/widget/modal_list_action_button_widget.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/duplicate_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/name_with_space_only_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/special_character_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class CreateNewLabelModal extends StatefulWidget {
  final List<Label> labels;

  const CreateNewLabelModal({super.key, required this.labels});

  @override
  State<CreateNewLabelModal> createState() => _CreateNewLabelModalState();
}

class _CreateNewLabelModalState extends State<CreateNewLabelModal> {
  final _imagePaths = Get.find<ImagePaths>();
  final _verifyNameInteractor = Get.find<VerifyNameInteractor>();

  final ValueNotifier<String?> _labelNameErrorText = ValueNotifier(null);
  final TextEditingController _nameInputController = TextEditingController();
  final FocusNode _nameInputFocusNode = FocusNode();

  List<String> _labelDisplayNameList = <String>[];

  @override
  void initState() {
    super.initState();
    _labelDisplayNameList = widget.labels.displayNameNotNullList;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return LayoutBuilder(builder: (_, constraints) {
      final currentScreenWidth = constraints.maxWidth;
      final currentScreenHeight = constraints.maxHeight;
      final isMobile = currentScreenWidth < ResponsiveUtils.minTabletWidth;

      Widget bodyWidget = Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 2,
            ),
          ],
        ),
        width: math.min(
          currentScreenWidth - 32,
          554,
        ),
        constraints: BoxConstraints(maxHeight: currentScreenHeight - 100),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 64,
                  alignment: Alignment.center,
                  padding: EdgeInsetsDirectional.only(
                    start: 32,
                    end: 32,
                    top: 16,
                    bottom: isMobile ? 0 : 16,
                  ),
                  child: Text(
                    appLocalizations.createANewLabel,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColor.m3SurfaceBackground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: 32,
                      end: 32,
                      bottom: isMobile ? 32 : 48,
                    ),
                    child: Text(
                      appLocalizations.organizeYourInboxWithACustomCategory,
                      style: ThemeUtils.textStyleInter400.copyWith(
                        color: AppColor.steelGrayA540,
                        fontSize: 13,
                        height: 20 / 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: 32,
                        end: 32,
                        bottom: isMobile ? 0 : 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: _labelNameErrorText,
                            builder: (_, errorText, __) {
                              return LabelInputFieldBuilder(
                                label: appLocalizations.labelName,
                                hintText: appLocalizations
                                    .pleaseEnterNameYourNewLabel,
                                textEditingController: _nameInputController,
                                focusNode: _nameInputFocusNode,
                                errorText: errorText,
                                arrangeHorizontally: false,
                                isLabelHasColon: false,
                                labelStyle:
                                    ThemeUtils.textStyleInter600().copyWith(
                                  fontSize: 14,
                                  height: 18 / 14,
                                  color: Colors.black,
                                ),
                                runSpacing: 16,
                                inputFieldMaxWidth: double.infinity,
                                onTextChange: (value) =>
                                    _onLabelNameInputChanged(
                                  appLocalizations,
                                  value,
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 26, bottom: 16),
                            child: Text(
                              appLocalizations.chooseALabelColor,
                              style: ThemeUtils.textStyleInter600().copyWith(
                                fontSize: 14,
                                height: 18 / 14,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: isMobile
                                  ? EdgeInsetsDirectional.zero
                                  : const EdgeInsetsDirectional.only(
                                      start: 32,
                                      end: 16,
                                    ),
                              child: const ColorsMapWidget(),
                            ),
                          ),
                          ModalListActionButtonWidget(
                            positiveLabel: appLocalizations.createLabel,
                            negativeLabel: appLocalizations.cancel,
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            onPositiveAction: _onCreateNewLabel,
                            onNegativeAction: _onCloseModal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            DefaultCloseButtonWidget(
              iconClose: _imagePaths.icCloseDialog,
              onTapActionCallback: _onCloseModal,
            ),
          ],
        ),
      );

      bodyWidget = Center(child: bodyWidget);

      if (PlatformInfo.isMobile) {
        bodyWidget = GestureDetector(
          onTap: _onCloseModal,
          child: Scaffold(
            backgroundColor: AppColor.blackAlpha20,
            body: GestureDetector(
              onTap: _clearInputFocus,
              child: bodyWidget,
            ),
          ),
        );
      }

      return bodyWidget;
    });
  }

  void _onLabelNameInputChanged(
      AppLocalizations appLocalizations, String value) {
    _labelNameErrorText.value = _verifyLabelName(appLocalizations, value);
  }

  String? _verifyLabelName(AppLocalizations appLocalizations, String value) {
    final result = _verifyNameInteractor.execute(
      value,
      _validators,
    );

    return result.fold(
      (failure) => failure is VerifyNameFailure
          ? failure.getMessageLabelError(appLocalizations)
          : null,
      (_) => null,
    );
  }

  List<Validator> get _validators => [
        EmptyNameValidator(),
        NameWithSpaceOnlyValidator(),
        DuplicateNameValidator(_labelDisplayNameList),
        SpecialCharacterValidator(),
      ];

  void _clearInputFocus() {
    _nameInputFocusNode.unfocus();
  }

  void _onCreateNewLabel() {
    _clearInputFocus();
    popBack();
  }

  void _onCloseModal() {
    _clearInputFocus();
    popBack();
  }

  @override
  void dispose() {
    _nameInputFocusNode.dispose();
    _nameInputController.dispose();
    _labelNameErrorText.dispose();
    _labelDisplayNameList = [];
    super.dispose();
  }
}
