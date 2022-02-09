
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnFilterEmailAction = void Function();
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

  AppBarThreadWidgetBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._presentationMailbox,
    this._listSelectionEmail,
    this._selectMode,
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
        child: Row(
          children: [
            if (_selectMode != SelectMode.ACTIVE) _buildEditButton(),
            if (_selectMode == SelectMode.ACTIVE) _buildBackButton(),
            if (_selectMode == SelectMode.ACTIVE) _buildCountItemSelected(),
            Expanded(child: _buildContentCenterAppBar()),
            _buildFilterButton(),
          ]
        )
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
        padding: EdgeInsets.only(left: 16),
        child: IconButton(
          color: AppColor.baseTextColor,
          icon: SvgPicture.asset(_imagePaths.icFilter, fit: BoxFit.fill),
          onPressed: () => _onFilterEmailAction?.call()
        )
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
          onTap: () => _onOpenListMailboxActionClick?.call(),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Container(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              constraints: BoxConstraints(maxWidth: _getMaxWidthAppBarTitle()),
              child: Text(
                '${_presentationMailbox?.name?.name.capitalizeFirstEach ?? ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 21, color: AppColor.colorNameEmail, fontWeight: FontWeight.w700))
            ))),
        Transform(
          transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
          child: Material(
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                child: IconButton(
                    padding: EdgeInsets.zero,
                    color: AppColor.baseTextColor,
                    icon: SvgPicture.asset(_imagePaths.icChevronDown, width: 20, height: 16, fit: BoxFit.fill),
                    onPressed: () => _onOpenListMailboxActionClick?.call())))
      ]
    );
  }

  double _getMaxWidthAppBarTitle() {
    var width = MediaQuery.of(_context).size.width;
    var widthSiblingsWidget = 220;
    if (_responsiveUtils.isTablet(_context)) {
      width = width * 0.7;
      widthSiblingsWidget = 300;
    } else if (_responsiveUtils.isDesktop(_context)) {
      width = width * 0.2;
      widthSiblingsWidget = 300;
    }
    final maxWidth = width - widthSiblingsWidget;
    return maxWidth;
  }
}