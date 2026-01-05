import 'dart:math' as math;

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/hex_color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/default_close_button_widget.dart';
import 'package:core/presentation/views/color/color_picker_modal.dart';
import 'package:core/presentation/views/color/colors_map_widget.dart';
import 'package:core/presentation/views/dialog/modal_list_action_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/base/widget/label_input_field_builder.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/duplicate_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/name_with_space_only_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnCreateNewLabelCallback = Function(Label label);

class CreateNewLabelModal extends StatefulWidget {
  final List<Label> labels;
  final LabelActionType actionType;
  final OnCreateNewLabelCallback onCreateNewLabelCallback;
  final Label? selectedLabel;

  const CreateNewLabelModal({
    super.key,
    required this.labels,
    required this.onCreateNewLabelCallback,
    this.actionType = LabelActionType.create,
    this.selectedLabel,
  });

  @override
  State<CreateNewLabelModal> createState() => _CreateNewLabelModalState();
}

class _CreateNewLabelModalState extends State<CreateNewLabelModal> {
  final _imagePaths = Get.find<ImagePaths>();
  final _verifyNameInteractor = Get.find<VerifyNameInteractor>();

  final ValueNotifier<String?> _labelNameErrorTextNotifier =
      ValueNotifier(null);
  final ValueNotifier<Color?> _labelSelectedColorNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _createLabelStateNotifier = ValueNotifier(false);
  final TextEditingController _nameInputController = TextEditingController();
  final FocusNode _nameInputFocusNode = FocusNode();

  List<String> _labelDisplayNameList = <String>[];
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    final selectedLabel = widget.selectedLabel;
    final labels = widget.labels;
    if (selectedLabel != null) {
      _selectedColor = selectedLabel.color?.value.toColor();
      _labelDisplayNameList = labels
          .getDisplayNameListWithoutSelectedLabel(selectedLabel);
    } else {
      _labelDisplayNameList = labels.displayNameNotNullList;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedLabel != null) {
        _nameInputController.text = selectedLabel.safeDisplayName;
        _nameInputFocusNode.requestFocus();
        _createLabelStateNotifier.value = true;
      }
    });
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
                _buildTitle(appLocalizations, isMobile, theme),
                _buildSubTitle(appLocalizations),
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
                          _buildLabelNameInputField(appLocalizations),
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
                              child: ValueListenableBuilder(
                                valueListenable: _labelSelectedColorNotifier,
                                builder: (_, value, __) {
                                  return ColorsMapWidget(
                                    imagePaths: _imagePaths,
                                    customColor: value,
                                    onOpenColorPicker: () =>
                                        _openColorPickerModal(appLocalizations),
                                    onSelectColorCallback: _updateLabelColor,
                                  );
                                },
                              ),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _createLabelStateNotifier,
                            builder: (_, value, __) {
                              return ModalListActionButtonWidget(
                                positiveLabel: widget.actionType.getModalPositiveAction(appLocalizations),
                                negativeLabel: appLocalizations.cancel,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 25,
                                ),
                                isPositiveActionEnabled: value,
                                onPositiveAction: _onCreateNewLabel,
                                onNegativeAction: _onCloseModal,
                              );
                            },
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

  Widget _buildTitle(
    AppLocalizations appLocalizations,
    bool isMobile,
    ThemeData theme,
  ) {
    return Container(
      height: 64,
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(
        start: 32,
        end: 32,
        top: 16,
        bottom: isMobile ? 0 : 16,
      ),
      child: Text(
        widget.actionType.getModalTitle(appLocalizations),
        style: theme.textTheme.headlineSmall?.copyWith(
          color: AppColor.m3SurfaceBackground,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSubTitle(AppLocalizations appLocalizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 32,
          end: 32,
          bottom: 24,
        ),
        child: Text(
          widget.actionType.getModalSubtitle(appLocalizations),
          style: ThemeUtils.textStyleInter400.copyWith(
            color: AppColor.steelGrayA540,
            fontSize: 13,
            height: 20 / 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLabelNameInputField(AppLocalizations appLocalizations) {
    return ValueListenableBuilder(
      valueListenable: _labelNameErrorTextNotifier,
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
    );
  }

  void _onLabelNameInputChanged(
    AppLocalizations appLocalizations,
    String value,
  ) {
    final errorText = _verifyLabelName(appLocalizations, value);
    _labelNameErrorTextNotifier.value = errorText;
    _createLabelStateNotifier.value = errorText == null;
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
      ];

  void _clearInputFocus() {
    _nameInputFocusNode.unfocus();
  }

  void _onCreateNewLabel() {
    _clearInputFocus();

    final newLabel = Label(
      displayName: _nameInputController.text,
      color: _selectedColor != null
          ? HexColor(_selectedColor!.toHexTriplet())
          : null,
    );
    widget.onCreateNewLabelCallback(newLabel);

    popBack();
  }

  void _onCloseModal() {
    _clearInputFocus();
    popBack();
  }

  void _updateLabelColor(Color? color) {
    _selectedColor = color;
  }

  void _onLabelColorChanged(Color? color) {
    _updateLabelColor(color);
    _labelSelectedColorNotifier.value = color;
  }

  Future<void> _openColorPickerModal(AppLocalizations appLocalizations) async {
    await Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: 'color-picker-modal',
      pageBuilder: (_, __, ___) => ColorPickerModal(
        imagePaths: _imagePaths,
        modalTitle: appLocalizations.chooseCustomColour,
        modalSubtitle: appLocalizations.chooseAColourForThisLabel,
        initialColor: _selectedColor,
        onSelectColorCallback: _onLabelColorChanged,
      ),
    );
  }

  @override
  void dispose() {
    _nameInputFocusNode.dispose();
    _nameInputController.dispose();
    _labelNameErrorTextNotifier.dispose();
    _labelSelectedColorNotifier.dispose();
    _createLabelStateNotifier.dispose();
    _labelDisplayNameList = [];
    super.dispose();
  }
}
