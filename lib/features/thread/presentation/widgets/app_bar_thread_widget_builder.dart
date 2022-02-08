
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnFilterEmailAction = void Function();
typedef OnOpenListMailboxActionClick = void Function();

class AppBarThreadWidgetBuilder {
  OnFilterEmailAction? _onFilterEmailAction;
  OnOpenListMailboxActionClick? _onOpenListMailboxActionClick;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final PresentationMailbox? _presentationMailbox;

  AppBarThreadWidgetBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._presentationMailbox,
  );

  void addOnFilterEmailAction(OnFilterEmailAction onFilterEmailAction) {
    _onFilterEmailAction = onFilterEmailAction;
  }

  void addOpenListMailboxActionClick(OnOpenListMailboxActionClick onOpenListMailboxActionClick) {
    _onOpenListMailboxActionClick = onOpenListMailboxActionClick;
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
            _buildEditButton(),
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
              onPressed: () {},
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
          icon: SvgPicture.asset(_imagePaths.icFilter, color: AppColor.baseTextColor, fit: BoxFit.fill),
          onPressed: () => _onFilterEmailAction?.call()
        )
      )
    );
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