import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/email_address_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnClickEmailAddressAction = void Function(EmailAddressActionType actionType);

class EmailAddressActionWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final EmailAddressActionType actionType;
  final OnClickEmailAddressAction onClick;

  const EmailAddressActionWidget({
    super.key,
    required this.imagePaths,
    required this.actionType,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onClick(actionType),
        child: Container(
          width: double.infinity,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              SvgPicture.asset(
                actionType.getContextMenuIcon(imagePaths),
                width: 20,
                height: 20,
                colorFilter: AppColor.steelGrayA540.asFilter(),
                fit: BoxFit.fill,
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Text(
                  actionType.getContextMenuTitle(AppLocalizations.of(context)),
                  style: ThemeUtils.textStyleInter400.copyWith(
                    fontSize: 14,
                    height: 21.01 / 14,
                    letterSpacing: -0.15,
                    color: AppColor.gray424244.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
