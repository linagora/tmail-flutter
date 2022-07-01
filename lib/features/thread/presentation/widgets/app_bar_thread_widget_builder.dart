
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
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

class AppBarThreadWidgetBuilder {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  OnFilterEmailAction? _onFilterEmailAction;
  OnOpenMailboxMenuActionClick? _onOpenMailboxMenuActionClick;
  OnEditThreadAction? _onEditThreadAction;
  OnCancelEditThread? _onCancelEditThread;
  OnEmailSelectionAction? _onEmailSelectionAction;

  final BuildContext _context;
  final PresentationMailbox? _currentMailbox;
  final List<PresentationEmail> _listSelectionEmail;
  final SelectMode _selectMode;
  final FilterMessageOption _filterMessageOption;

  AppBarThreadWidgetBuilder(
    this._context,
    this._currentMailbox,
    this._listSelectionEmail,
    this._selectMode,
    this._filterMessageOption,
  );

  void addOnFilterEmailAction(OnFilterEmailAction onFilterEmailAction) {
    _onFilterEmailAction = onFilterEmailAction;
  }

  void addOpenMailboxMenuActionClick(OnOpenMailboxMenuActionClick actionClick) {
    _onOpenMailboxMenuActionClick = actionClick;
  }

  void addOnEditThreadAction(OnEditThreadAction onEditThreadAction) {
    _onEditThreadAction = onEditThreadAction;
  }

  void addOnCancelEditThread(OnCancelEditThread onCancelEditThread) {
    _onCancelEditThread = onCancelEditThread;
  }

  void addOnEmailSelectionAction(OnEmailSelectionAction onEmailSelectionAction) {
    _onEmailSelectionAction = onEmailSelectionAction;
  }

  Widget build() {
    return Container(
      key: const Key('app_bar_thread_widget'),
      alignment: Alignment.topCenter,
      color: Colors.white,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(
          vertical: _selectMode == SelectMode.INACTIVE ? 16 : 11,
          horizontal: 8),
      child: MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.zero),
        child: _buildAppBar()
      )
    );
  }

  Widget _buildAppBar() {
    if (BuildUtils.isWeb) {
      return _selectMode == SelectMode.INACTIVE
          ? _buildBodyAppBarForWeb()
          : _buildBodyAppBarForWebSelection();
    } else {
      return _selectMode == SelectMode.INACTIVE
          ? _buildBodyAppBarForMobile()
          : _buildBodyAppBarForMobileSelection();
    }
  }

  Widget _buildBodyAppBarForWeb() {
    return Row(children: [
      if (_responsiveUtils.hasLeftMenuDrawerActive(_context))
        _buildMenuButton(),
      if (_responsiveUtils.hasLeftMenuDrawerActive(_context))
        const SizedBox(width: 16),
      Expanded(child: Text(
          _currentMailbox?.name?.name.capitalizeFirstEach ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 21, color: Colors.black, fontWeight: FontWeight.bold))),
      _buildFilterButton(),
    ]);
  }

  Widget _buildBodyAppBarForWebSelection() {
    return Row(children: [
      buildIconWeb(
          icon: SvgPicture.asset(_imagePaths.icCloseComposer,
              color: AppColor.colorTextButton,
              fit: BoxFit.fill),
          minSize: 25,
          iconSize: 25,
          iconPadding: const EdgeInsets.all(5),
          splashRadius: 15,
          tooltip: AppLocalizations.of(_context).cancel,
          onTap: () => _onCancelEditThread?.call()),
      Expanded(child: Text(
        AppLocalizations.of(_context).count_email_selected(_listSelectionEmail.length),
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
                  ? _imagePaths.icRead
                  : _imagePaths.icUnread,
              fit: BoxFit.fill),
          tooltip: _listSelectionEmail.isAllEmailRead
              ? AppLocalizations.of(_context).unread
              : AppLocalizations.of(_context).read,
          onTap: () => _onEmailSelectionAction?.call(
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
              ? AppLocalizations.of(_context).not_starred
              : AppLocalizations.of(_context).starred,
          onTap: () => _onEmailSelectionAction?.call(
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
              tooltip: AppLocalizations.of(_context).move,
              onTap: () => _onEmailSelectionAction?.call(EmailActionType.moveToMailbox, _listSelectionEmail)),
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
                  ? AppLocalizations.of(_context).un_spam
                  : AppLocalizations.of(_context).mark_as_spam,
              onTap: () => _currentMailbox?.isSpam == true
                  ? _onEmailSelectionAction?.call(EmailActionType.unSpam, _listSelectionEmail)
                  : _onEmailSelectionAction?.call(EmailActionType.moveToSpam, _listSelectionEmail)),
          const SizedBox(width: 5),
        ],
      buildIconWeb(
          minSize: 25,
          iconSize: 25,
          iconPadding: const EdgeInsets.all(5),
          splashRadius: 15,
          icon: SvgPicture.asset(
              _imagePaths.icDeleteComposer,
              width: 18,
              height: 18,
              color: AppColor.textFieldErrorBorderColor,
              fit: BoxFit.fill),
          tooltip: _currentMailbox?.role != PresentationMailbox.roleTrash
              ? AppLocalizations.of(_context).move_to_trash
              : AppLocalizations.of(_context).delete_permanently,
          onTap: () => _currentMailbox?.isTrash == true
              ? _onEmailSelectionAction?.call(EmailActionType.deletePermanently, _listSelectionEmail)
              : _onEmailSelectionAction?.call(EmailActionType.moveToTrash, _listSelectionEmail)),
      const SizedBox(width: 10),
    ]);
  }

  Widget _buildBodyAppBarForMobile() {
    return Row(children: [
      Expanded(child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(left: 0,child: _buildEditButton()),
            Positioned(right: 0, child: _buildFilterButton()),
            _filterMessageOption.getTitle(_context).isNotEmpty
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: _buildContentCenterAppBar()),
                    Transform(
                        transform: Matrix4.translationValues(
                            _getXTranslationValues(),
                            -8.0,
                            0.0),
                        child: Text(
                            _filterMessageOption.getTitle(_context),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColor.colorContentEmail)))
                  ])
                : Padding(
                    padding: const EdgeInsets.only(left: 60, right: 40),
                    child: _buildContentCenterAppBar()),
          ]
      ))
    ]);
  }

  Widget _buildBodyAppBarForMobileSelection() {
    return Row(children: [
      Expanded(child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(left: 0, child: _buildBackButton()),
            Positioned(left: 40, child: _buildCountItemSelected()),
            Positioned(right: 0, child: _buildFilterButton()),
            _filterMessageOption.getTitle(_context).isNotEmpty
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: _buildContentCenterAppBar()),
                    Transform(
                        transform: Matrix4.translationValues(
                            _responsiveUtils.isDesktop(_context) ? -2.0 : -16.0,
                            -8.0,
                            0.0),
                        child: Text(
                            _filterMessageOption.getTitle(_context),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColor.colorContentEmail)))
                  ])
                : Padding(
                    padding: const EdgeInsets.only(left: 60, right: 40),
                    child: _buildContentCenterAppBar()),
          ]
      ))
    ]);
  }

  Widget _buildEditButton() {
    return Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () => _onEditThreadAction?.call(),
              child: Text(
                AppLocalizations.of(_context).edit,
                style: const TextStyle(
                    fontSize: 17,
                    color: AppColor.colorTextButton),
              ),
            )
        )
    );
  }

  Widget _buildFilterButton() {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            onTap: () {
              if (_onFilterEmailAction != null
                  && _responsiveUtils.isScreenWithShortestSide(_context)) {
                _onFilterEmailAction!.call(_filterMessageOption, null);
              }
            },
            child: SvgPicture.asset(
              _imagePaths.icFilter,
              color: _filterMessageOption == FilterMessageOption.all
                  ? AppColor.colorFilterMessageDisabled
                  : AppColor.colorFilterMessageEnabled,
              fit: BoxFit.fill),
            onTapDown: (detail) {
              if (_onFilterEmailAction != null
                  && !_responsiveUtils.isScreenWithShortestSide(_context)) {
                final screenSize = MediaQuery.of(_context).size;
                final offset = detail.globalPosition;
                final position = RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy,
                  screenSize.width - offset.dx,
                  screenSize.height - offset.dy,
                );
                _onFilterEmailAction!.call(_filterMessageOption, position);
              }
            })
      )
    );
  }

  Widget _buildMenuButton() {
    return buildIconWeb(
        minSize: 20,
        iconSize: 20,
        iconPadding: const EdgeInsets.all(3),
        splashRadius: 15,
        icon: SvgPicture.asset(_imagePaths.icMenuDrawer, fit: BoxFit.fill),
        onTap:() => _onOpenMailboxMenuActionClick?.call());
  }

  Widget _buildBackButton() {
    return buildIconWeb(
        icon: SvgPicture.asset(_imagePaths.icBack,
            width: 20,
            height: 20,
            color: AppColor.colorTextButton,
            fit: BoxFit.fill),
        onTap:() => _onCancelEditThread?.call());
  }

  Widget _buildCountItemSelected() {
    return Padding(
        padding: EdgeInsets.zero,
        child: Text(
            '${_listSelectionEmail.length}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 17,
                color: AppColor.colorTextButton)));
  }

  Widget _buildContentCenterAppBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (_responsiveUtils.hasLeftMenuDrawerActive(_context)) {
              _onOpenMailboxMenuActionClick?.call();
            }
          },
          child: Padding(
            padding: (_responsiveUtils.hasLeftMenuDrawerActive(_context))
                ? EdgeInsets.zero
                : const EdgeInsets.only(bottom: 8, top: 8),
            child: Container(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              constraints: BoxConstraints(maxWidth: _getMaxWidthAppBarTitle()),
              child: Text(
                _currentMailbox?.name?.name.capitalizeFirstEach ?? '',
                maxLines: 1,
                overflow: CommonTextStyle.defaultTextOverFlow,
                style: const TextStyle(
                    fontSize: 21,
                    color: AppColor.colorNameEmail,
                    fontWeight: FontWeight.w700))
            ))),
        if (_responsiveUtils.hasLeftMenuDrawerActive(_context))
          Transform(
            transform: Matrix4.translationValues(-8.0, 0.0, 0.0),
            child: IconButton(
              padding: EdgeInsets.zero,
              color: AppColor.baseTextColor,
              icon: SvgPicture.asset(_imagePaths.icChevronDown,
                  width: 20,
                  height: 16,
                  fit: BoxFit.fill),
              onPressed: () => _onOpenMailboxMenuActionClick?.call()
            )
          )
      ]
    );
  }

  double _getMaxWidthAppBarTitle() {
    var width = MediaQuery.of(_context).size.width;
    var widthSiblingsWidget = 220;
    if (_responsiveUtils.isTablet(_context) || _responsiveUtils.isLandscapeMobile(_context)) {
      width = width * 0.7;
      widthSiblingsWidget = 250;
    } else if (_responsiveUtils.isTabletLarge(_context)) {
      width = width * 0.6;
      widthSiblingsWidget = 250;
    } else if (_responsiveUtils.isDesktop(_context)) {
      width = width * 0.25;
      widthSiblingsWidget = 150;
    }
    final maxWidth = width > widthSiblingsWidget
        ? width - widthSiblingsWidget
        : 0.0;
    return maxWidth;
  }

  double _getXTranslationValues() {
    if (BuildUtils.isWeb) {
      return _responsiveUtils.isDesktop(_context) && BuildUtils.isWeb
          ? -2.0
          : -16.0;
    } else {
      return _responsiveUtils.isTabletLarge(_context) ? 0.0 : -16.0;
    }
  }
}