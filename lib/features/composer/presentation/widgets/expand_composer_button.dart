import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/composer/presentation/utils/composer_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ExpandComposerButton extends StatelessWidget {

  final ImagePaths imagePaths;
  final int countComposerHidden;
  final VoidCallback onToggleDisplayComposerAction;

  const ExpandComposerButton({
    super.key,
    required this.imagePaths,
    required this.countComposerHidden,
    required this.onToggleDisplayComposerAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12))
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => {},
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          color: Colors.white,
          width: ComposerUtils.composerExpandMoreButtonMaxWidth,
          height: ComposerUtils.minimizeHeight,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
          child: Row(
            children: [
              SvgPicture.asset(imagePaths.icDoubleArrowUp),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '+$countComposerHidden ${AppLocalizations.of(context).more.toLowerCase()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ]
          )
        ),
      ),
    );
  }
}