
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/filter_message_option.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnFilterEmailAction = void Function(FilterMessageOption, RelativeRect? position);
typedef OnEditThreadAction = void Function();
typedef OnOpenListMailboxActionClick = void Function();
typedef OnCancelEditThread = void Function();

class AppBarThreadWidgetBuilder {
  OnFilterEmailAction? _onFilterEmailAction;
  OnOpenListMailboxActionClick? _onOpenListMailboxActionClick;
  OnEditThreadAction? _onEditThreadAction;
  OnCancelEditThread? _onCancelEditThread;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final PresentationMailbox? _presentationMailbox;
  final List<PresentationEmail> _listSelectionEmail;
  final SelectMode _selectMode;
  final FilterMessageOption _filterMessageOption;

  AppBarThreadWidgetBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._presentationMailbox,
    this._listSelectionEmail,
    this._selectMode,
    this._filterMessageOption,
  );

  void addOnFilterEmailAction(OnFilterEmailAction onFilterEmailAction) {
    _onFilterEmailAction = onFilterEmailAction;
  }

  void addOpenListMailboxActionClick(OnOpenListMailboxActionClick onOpenListMailboxActionClick) {
    _onOpenListMailboxActionClick = onOpenListMailboxActionClick;
  }

  void addOnEditThreadAction(OnEditThreadAction onEditThreadAction) {
    _onEditThreadAction = onEditThreadAction;
  }

  void addOnCancelEditThread(OnCancelEditThread onCancelEditThread) {
    _onCancelEditThread = onCancelEditThread;
  }

  Widget build() {
    return Container(
      key: Key('app_bar_thread_widget'),
      alignment: Alignment.topCenter,
      color: Colors.white,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.only(left: 8, top: 16, bottom: 8, right: 8),
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: Row(children: [
          Expanded(child: Stack(
            alignment: Alignment.center,
            children: [
              if (_selectMode != SelectMode.ACTIVE)
                Positioned(left: 0,child: _buildEditButton()),
              if (_selectMode == SelectMode.ACTIVE)
                Positioned(left: 0, child: _buildBackButton()),
              if (_selectMode == SelectMode.ACTIVE)
                Positioned(left: 40, child: _buildCountItemSelected()),
              Positioned(right: 0, child: _buildFilterButton()),
              _filterMessageOption.getTitle(_context).isNotEmpty
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Padding(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      child: _buildContentCenterAppBar()),
                    Transform(
                      transform: Matrix4.translationValues(_responsiveUtils.isDesktop(_context) ? -2.0 : -16.0, -8.0, 0.0),
                      child: Text(
                          _filterMessageOption.getTitle(_context),
                          style: TextStyle(fontSize: 11, color: AppColor.colorContentEmail)))
                  ])
                : Padding(
                    padding: EdgeInsets.only(left: 60, right: 40),
                    child: _buildContentCenterAppBar()),
            ]
          ))
        ])
      )
    );
  }

  Widget _buildEditButton() {
    return Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: Padding(
            padding: EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () => _onEditThreadAction?.call(),
              child: Text(
                AppLocalizations.of(_context).edit,
                style: TextStyle(fontSize: 17, color: AppColor.colorTextButton),
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
        padding: EdgeInsets.only(left: 16, right: 16),
        child: GestureDetector(
            onTap: () {
              if (_onFilterEmailAction != null && _responsiveUtils.isMobileDevice(_context)) {
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
              if (_onFilterEmailAction != null && !_responsiveUtils.isMobileDevice(_context)) {
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

  Widget _buildBackButton() {
    return Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: IconButton(
            color: AppColor.baseTextColor,
            icon: SvgPicture.asset(
                _imagePaths.icBack,
                width: 20,
                height: 20,
                color: AppColor.colorTextButton,
                fit: BoxFit.fill),
            onPressed: () => _onCancelEditThread?.call()
        )
    );
  }

  Widget _buildCountItemSelected() {
    return Padding(
        padding: EdgeInsets.zero,
        child: Text(
            '${_listSelectionEmail.length}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 17, color: AppColor.colorTextButton)));
  }

  Widget _buildContentCenterAppBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => !_responsiveUtils.isDesktop(_context) ? _onOpenListMailboxActionClick?.call() : null,
          child: Padding(
            padding: !_responsiveUtils.isDesktop(_context) ? EdgeInsets.zero : EdgeInsets.only(bottom: 8, top: 8),
            child: Container(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              constraints: BoxConstraints(maxWidth: _getMaxWidthAppBarTitle()),
              child: Text(
                '${_presentationMailbox?.name?.name.capitalizeFirstEach ?? ''}',
                maxLines: 1,
                overflow: GetPlatform.isWeb ? TextOverflow.clip : TextOverflow.ellipsis,
                style: TextStyle(fontSize: 21, color: AppColor.colorNameEmail, fontWeight: FontWeight.w700))
            ))),
        if (!_responsiveUtils.isDesktop(_context))
          Transform(
            transform: Matrix4.translationValues(-8.0, 0.0, 0.0),
            child: IconButton(
              padding: EdgeInsets.zero,
              color: AppColor.baseTextColor,
              icon: SvgPicture.asset(_imagePaths.icChevronDown, width: 20, height: 16, fit: BoxFit.fill),
              onPressed: () => !_responsiveUtils.isDesktop(_context) ? _onOpenListMailboxActionClick?.call() : null))
      ]
    );
  }

  double _getMaxWidthAppBarTitle() {
    var width = MediaQuery.of(_context).size.width;
    var widthSiblingsWidget = 220;
    if (_responsiveUtils.isTablet(_context)) {
      width = width * 0.7;
      widthSiblingsWidget = 300;
    } else if (_responsiveUtils.isTabletLarge(_context)) {
      width = width * 0.35;
      widthSiblingsWidget = 250;
    } else if (_responsiveUtils.isDesktop(_context)) {
      width = width * 0.25;
      widthSiblingsWidget = 150;
    }
    final maxWidth = width > widthSiblingsWidget ? width - widthSiblingsWidget : 0.0;
    return maxWidth;
  }
}