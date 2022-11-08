
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnFilterEmailAction = void Function(FilterMessageOption, RelativeRect? position);
typedef OnEditThreadAction = void Function();
typedef OnOpenMailboxMenuActionClick = void Function();
typedef OnCancelEditThread = void Function();
typedef OnEmailSelectionAction = void Function(EmailActionType actionType, List<PresentationEmail>);

class AppBarThreadWidgetBuilder extends StatelessWidget {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final OnFilterEmailAction? onFilterEmailAction;
  final OnOpenMailboxMenuActionClick? onOpenMailboxMenuActionClick;
  final OnEditThreadAction? onEditThreadAction;
  final OnCancelEditThread? onCancelEditThread;
  final OnEmailSelectionAction? onEmailSelectionAction;

  final PresentationMailbox? _currentMailbox;
  final List<PresentationEmail> _listSelectionEmail;
  final SelectMode _selectMode;
  final FilterMessageOption _filterMessageOption;

  AppBarThreadWidgetBuilder(
    this._currentMailbox,
    this._listSelectionEmail,
    this._selectMode,
    this._filterMessageOption, {
    Key? key,
    this.onFilterEmailAction,
    this.onOpenMailboxMenuActionClick,
    this.onEditThreadAction,
    this.onCancelEditThread,
    this.onEmailSelectionAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
          key: const Key('app_bar_thread_widget'),
          alignment: Alignment.center,
          height: 56,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildAppBar(context, constraints)
      );
    });
  }

  Widget _buildAppBar(BuildContext context, BoxConstraints constraints) {
    if (BuildUtils.isWeb) {
      return _selectMode == SelectMode.INACTIVE
          ? _buildBodyAppBarForWeb(context)
          : _buildBodyAppBarForWebSelection(context);
    } else {
      return _selectMode == SelectMode.INACTIVE
          ? _buildBodyAppBarForMobile(context, constraints)
          : _buildBodyAppBarForMobileSelection(context, constraints);
    }
  }

  Widget _buildBodyAppBarForWeb(BuildContext context) {
    return Row(children: [
      if (_responsiveUtils.hasLeftMenuDrawerActive(context))
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildMenuButton(),
        ),
      Expanded(child: Text(
          _currentMailbox?.name?.name.capitalizeFirstEach ?? '',
          maxLines: 1,
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap,
          style: const TextStyle(
              fontSize: 21,
              color: Colors.black,
              fontWeight: FontWeight.bold))),
      _buildFilterButton(context),
    ]);
  }

  Widget _buildBodyAppBarForWebSelection(BuildContext context) {
    return Row(children: [
      buildIconWeb(
          icon: SvgPicture.asset(_imagePaths.icCloseComposer,
              color: AppColor.colorTextButton,
              fit: BoxFit.fill),
          minSize: 25,
          iconSize: 25,
          iconPadding: const EdgeInsets.all(5),
          splashRadius: 15,
          tooltip: AppLocalizations.of(context).cancel,
          onTap: () => onCancelEditThread?.call()),
      Expanded(child: Text(
        AppLocalizations.of(context).count_email_selected(_listSelectionEmail.length),
        style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppColor.colorTextButton))),
      buildIconWeb(
          minSize: 25,
          iconSize: 25,
          iconPadding: const EdgeInsets.all(5),
          splashRadius: 15,
          icon: SvgPicture.asset(
              _listSelectionEmail.isAllEmailRead
                  ? _imagePaths.icUnread
                  : _imagePaths.icRead,
              fit: BoxFit.fill),
          tooltip: _listSelectionEmail.isAllEmailRead
              ? AppLocalizations.of(context).unread
              : AppLocalizations.of(context).read,
          onTap: () => onEmailSelectionAction?.call(
              _listSelectionEmail.isAllEmailRead
                  ? EmailActionType.markAsUnread
                  : EmailActionType.markAsRead,
              _listSelectionEmail)),
      const SizedBox(width: 5),
      buildIconWeb(
          minSize: 25,
          iconSize: 25,
          iconPadding: const EdgeInsets.all(5),
          splashRadius: 15,
          icon: SvgPicture.asset(
              _listSelectionEmail.isAllEmailStarred
                  ? _imagePaths.icUnStar
                  : _imagePaths.icStar,
              fit: BoxFit.fill),
          tooltip: _listSelectionEmail.isAllEmailStarred
              ? AppLocalizations.of(context).not_starred
              : AppLocalizations.of(context).starred,
          onTap: () => onEmailSelectionAction?.call(
              _listSelectionEmail.isAllEmailStarred
                  ? EmailActionType.unMarkAsStarred
                  : EmailActionType.markAsStarred,
              _listSelectionEmail)),
      const SizedBox(width: 5),
      if (_currentMailbox?.isDrafts == false)
        ... [
          buildIconWeb(
              minSize: 25,
              iconSize: 25,
              iconPadding: const EdgeInsets.all(5),
              splashRadius: 15,
              icon: SvgPicture.asset(_imagePaths.icMove, fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).move,
              onTap: () => onEmailSelectionAction?.call(EmailActionType.moveToMailbox, _listSelectionEmail)),
          const SizedBox(width: 5),
          buildIconWeb(
              minSize: 25,
              iconSize: 25,
              iconPadding: const EdgeInsets.all(5),
              splashRadius: 15,
              icon: SvgPicture.asset(_currentMailbox?.isSpam == true
                  ? _imagePaths.icNotSpam : _imagePaths.icSpam,
                  fit: BoxFit.fill),
              tooltip: _currentMailbox?.isSpam == true
                  ? AppLocalizations.of(context).un_spam
                  : AppLocalizations.of(context).mark_as_spam,
              onTap: () => _currentMailbox?.isSpam == true
                  ? onEmailSelectionAction?.call(EmailActionType.unSpam, _listSelectionEmail)
                  : onEmailSelectionAction?.call(EmailActionType.moveToSpam, _listSelectionEmail)),
          const SizedBox(width: 5),
        ],
      buildIconWeb(
          minSize: 25,
          iconSize: 25,
          iconPadding: const EdgeInsets.all(5),
          splashRadius: 15,
          icon: SvgPicture.asset(
              canDeletePermanently ? _imagePaths.icDeleteComposer : _imagePaths.icDelete,
              color: canDeletePermanently ? AppColor.colorDeletePermanentlyButton : AppColor.primaryColor,
              width: 20,
              height: 20,
              fit: BoxFit.fill),
          tooltip: canDeletePermanently
              ? AppLocalizations.of(context).delete_permanently
              : AppLocalizations.of(context).move_to_trash,
          onTap: () => canDeletePermanently
              ? onEmailSelectionAction?.call(EmailActionType.deletePermanently, _listSelectionEmail)
              : onEmailSelectionAction?.call(EmailActionType.moveToTrash, _listSelectionEmail)),
      const SizedBox(width: 10),
    ]);
  }

  bool get canDeletePermanently {
    return _currentMailbox?.isTrash == true || _currentMailbox?.isDrafts == true;
  }

  Widget _buildBodyAppBarForMobile(BuildContext context, BoxConstraints constraints) {
    return Stack(
        alignment: Alignment.center,
        children: [
          if (_filterMessageOption.getTitle(context).isNotEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildContentCenterAppBar(context, constraints),
                  Transform(
                      transform: Matrix4.translationValues(
                          _getXTranslationValues(context),
                          -8.0,
                          0.0),
                      child: Text(
                          _filterMessageOption.getTitle(context),
                          style: const TextStyle(fontSize: 11, color: AppColor.colorContentEmail)))
                ]),
            )
          else
            Center(child: _buildContentCenterAppBar(context, constraints)),
          Positioned(left: 0, child: _buildEditButton(context)),
          Positioned(right: 0, child: _buildFilterButton(context))
        ]
    );
  }

  Widget _buildBodyAppBarForMobileSelection(BuildContext context, BoxConstraints constraints) {
    return Stack(
        alignment: Alignment.center,
        children: [
          if (_filterMessageOption.getTitle(context).isNotEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildContentCenterAppBar(context, constraints),
                    Transform(
                        transform: Matrix4.translationValues(
                            _responsiveUtils.isDesktop(context) ? -2.0 : -16.0,
                            -8.0,
                            0.0),
                        child: Text(
                            _filterMessageOption.getTitle(context),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColor.colorContentEmail)))
                  ]),
              )
          else
              Center(child: _buildContentCenterAppBar(context, constraints)),
          Positioned(left: 0, child: _buildCancelSelection()),
          Positioned(right: 0, child: _buildFilterButton(context))
        ]
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Material(
        borderRadius: BorderRadius.circular(15),
        color: Colors.transparent,
        child: TextButton(
          onPressed: onEditThreadAction,
          child: Text(
            AppLocalizations.of(context).edit,
            style: const TextStyle(
                fontSize: 17,
                color: AppColor.colorTextButton),
          ),
        )
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      color: Colors.transparent,
      child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            if (onFilterEmailAction != null
                && _responsiveUtils.isScreenWithShortestSide(context)) {
              onFilterEmailAction!.call(_filterMessageOption, null);
            }
          },
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: SvgPicture.asset(
              _imagePaths.icFilter,
              color: _filterMessageOption == FilterMessageOption.all
                  ? AppColor.colorFilterMessageDisabled
                  : AppColor.colorFilterMessageEnabled,
              fit: BoxFit.fill),
          ),
          onTapDown: (detail) {
            if (onFilterEmailAction != null
                && !_responsiveUtils.isScreenWithShortestSide(context)) {
              final screenSize = MediaQuery.of(context).size;
              final offset = detail.globalPosition;
              final position = RelativeRect.fromLTRB(
                offset.dx,
                offset.dy,
                screenSize.width - offset.dx,
                screenSize.height - offset.dy,
              );
              onFilterEmailAction!.call(_filterMessageOption, position);
            }
          })
    );
  }

  Widget _buildMenuButton() {
    return buildIconWeb(
        minSize: 20,
        iconSize: 20,
        iconPadding: const EdgeInsets.all(3),
        splashRadius: 15,
        icon: SvgPicture.asset(_imagePaths.icMenuDrawer, fit: BoxFit.fill),
        onTap: onOpenMailboxMenuActionClick);
  }

  Widget _buildCancelSelection() {
    return Material(
      borderRadius: BorderRadius.circular(15),
      color: Colors.transparent,
      child: InkWell(
          onTap: onCancelEditThread,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(_imagePaths.icBack,
                      width: 20,
                      height: 20,
                      color: AppColor.colorTextButton,
                      fit: BoxFit.fill),
                  const SizedBox(width: 8),
                  _buildCountItemSelected()
                ]),
          )),
    );
  }

  Widget _buildCountItemSelected() {
    return Padding(
        padding: EdgeInsets.zero,
        child: Text(
            '${_listSelectionEmail.length}',
            maxLines: 1,
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap,
            style: const TextStyle(
                fontSize: 17,
                color: AppColor.colorTextButton)));
  }

  Widget _buildContentCenterAppBar(BuildContext context, BoxConstraints constraints) {
    if (_responsiveUtils.hasLeftMenuDrawerActive(context)) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpenMailboxMenuActionClick,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            color: Colors.transparent,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      constraints: BoxConstraints(maxWidth: constraints.maxWidth - 220),
                      child: Text(
                          _currentMailbox?.name?.name.capitalizeFirstEach ?? '',
                          maxLines: 1,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          style: const TextStyle(
                              fontSize: 21,
                              color: AppColor.colorNameEmail,
                              fontWeight: FontWeight.w700))),
                  SvgPicture.asset(_imagePaths.icChevronDown)
                ]
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  double _getXTranslationValues(BuildContext context) {
    if (BuildUtils.isWeb) {
      return _responsiveUtils.isWebDesktop(context) ? -2.0 : -16.0;
    } else {
      return _responsiveUtils.isTabletLarge(context) ? 0.0 : -16.0;
    }
  }
}