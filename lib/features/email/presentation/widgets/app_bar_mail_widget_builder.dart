
import 'package:core/core.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnBackActionClick = void Function();
typedef OnEmailActionClick = void Function(PresentationEmail, EmailActionType);
typedef OnMoreActionClick = void Function(PresentationEmail, RelativeRect?);

class AppBarMailWidgetBuilder extends StatelessWidget {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final PresentationEmail _presentationEmail;
  final List<Widget>? optionsWidget;
  final PresentationMailbox? mailboxContain;
  final bool isSearchIsRunning;
  final OnBackActionClick? onBackActionClick;
  final OnEmailActionClick? onEmailActionClick;
  final OnMoreActionClick? onMoreActionClick;

  AppBarMailWidgetBuilder(
    this._presentationEmail,
    {
      Key? key,
      this.mailboxContain,
      this.onBackActionClick,
      this.onEmailActionClick,
      this.onMoreActionClick,
      this.optionsWidget,
      this.isSearchIsRunning = false,
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('app_bar_messenger_widget'),
      color: Colors.transparent,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        if (_supportDisplayMailboxNameTitle(context))
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onBackActionClick?.call(),
              customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Tooltip(
                message: isSearchIsRunning
                    ? AppLocalizations.of(context).backToSearchResults
                    : AppLocalizations.of(context).back,
                child: Container(
                  color: Colors.transparent,
                  height: 32,
                  padding: DirectionUtils.isDirectionRTLByLanguage(context)
                    ? const EdgeInsetsDirectional.only(end: 10)
                    : const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    SvgPicture.asset(
                      DirectionUtils.isDirectionRTLByLanguage(context)
                        ? _imagePaths.icArrowRight
                        : _imagePaths.icBack,
                      width: DirectionUtils.isDirectionRTLByLanguage(context) ? null : 16,
                      height: DirectionUtils.isDirectionRTLByLanguage(context) ? null : 16,
                      colorFilter: AppColor.colorTextButton.asFilter(),
                      fit: BoxFit.fill),
                    if (!isSearchIsRunning)
                      Container(
                        margin: DirectionUtils.isDirectionRTLByLanguage(context)
                          ? null
                          : const EdgeInsetsDirectional.only(start: 8),
                        constraints: BoxConstraints(
                            maxWidth: _responsiveUtils.getSizeScreenWidth(context) - 250),
                        child: Text(
                            mailboxContain?.getDisplayName(context) ?? '',
                            maxLines: 1,
                            overflow: CommonTextStyle.defaultTextOverFlow,
                            softWrap: CommonTextStyle.defaultSoftWrap,
                            style: const TextStyle(fontSize: 17, color: AppColor.colorTextButton)),
                      ),
                  ]),
                ),
              ),
            ),
          ),
        const Spacer(),
        _buildListOptionButton(context),
      ])
    );
  }

  bool _supportDisplayMailboxNameTitle(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return _responsiveUtils.isDesktop(context) ||
          _responsiveUtils.isMobile(context) ||
          _responsiveUtils.isTablet(context) ||
          isSearchIsRunning;
    } else {
      return _responsiveUtils.isPortraitMobile(context) ||
          _responsiveUtils.isLandscapeMobile(context) ||
          _responsiveUtils.isTablet(context) ||
          isSearchIsRunning;
    }
  }

  Widget _buildListOptionButton(BuildContext context) {
    return Row(
      children: [
        if(optionsWidget != null)
          ...optionsWidget!,
        buildIconWeb(
            icon: SvgPicture.asset(
                _imagePaths.icMoveEmail,
                width: IconUtils.defaultIconSize,
                height: IconUtils.defaultIconSize,
                fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).move_message,
            onTap: () => onEmailActionClick?.call(
                _presentationEmail,
                EmailActionType.moveToMailbox)),
        buildIconWeb(
          icon: SvgPicture.asset(
              _presentationEmail.hasStarred
                ? _imagePaths.icStar
                : _imagePaths.icUnStar,
              width: IconUtils.defaultIconSize,
              height: IconUtils.defaultIconSize,
              fit: BoxFit.fill),
          tooltip: _presentationEmail.hasStarred
              ? AppLocalizations.of(context).not_starred
              : AppLocalizations.of(context).mark_as_starred,
          onTap: () => onEmailActionClick?.call(_presentationEmail,
              _presentationEmail.hasStarred
                  ? EmailActionType.unMarkAsStarred
                  : EmailActionType.markAsStarred)),
        buildIconWeb(
            icon: SvgPicture.asset(
                _imagePaths.icDeleteComposer,
                colorFilter: mailboxContain?.isTrash == false
                  ? AppColor.colorTextButton.asFilter()
                  : AppColor.colorDeletePermanentlyButton.asFilter(),
                width: PlatformInfo.isWeb ? 18 : 20,
                height: PlatformInfo.isWeb ? 18 : 20,
                fit: BoxFit.fill),
            tooltip: mailboxContain?.isTrash == false
                ? AppLocalizations.of(context).move_to_trash
                : AppLocalizations.of(context).delete_permanently,
            onTap: () {
              if (mailboxContain?.isTrash == false) {
                onEmailActionClick?.call(
                    _presentationEmail,
                    EmailActionType.moveToTrash);
              } else {
                onEmailActionClick?.call(
                    _presentationEmail,
                    EmailActionType.deletePermanently);
              }
            }),
        buildIconWebHasPosition(
          context,
          tooltip: AppLocalizations.of(context).more,
          icon: SvgPicture.asset(
              _imagePaths.icMore,
              width: IconUtils.defaultIconSize,
              height: IconUtils.defaultIconSize,
              fit: BoxFit.fill),
          onTap: () {
            if (_responsiveUtils.isPortraitMobile(context) ||
                _responsiveUtils.isLandscapeMobile(context)) {
              onMoreActionClick?.call(_presentationEmail, null);
            }
          },
          onTapDown: (position) {
            if (!_responsiveUtils.isPortraitMobile(context) &&
                !_responsiveUtils.isLandscapeMobile(context)) {
              onMoreActionClick?.call(_presentationEmail, position);
            }
          }
        ),
      ]
    );
  }
}