import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/base/widget/email_avatar_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/presentation_local_email_draft_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/presentation_local_email_draft.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSelectLocalEmailDraftAction = void Function(
    PresentationLocalEmailDraft);
typedef OnDiscardLocalEmailDraftAction = void Function(
    PresentationLocalEmailDraft);
typedef OnEditLocalEmailDraftAction = void Function(
    PresentationLocalEmailDraft);
typedef OnSaveAsDraftLocalEmailDraftAction = void Function(
    PresentationLocalEmailDraft);

class LocalEmailDraftItemWidget extends StatelessWidget {
  final PresentationLocalEmailDraft draftLocal;
  final bool isOldest;
  final ImagePaths imagePaths;
  final OnSelectLocalEmailDraftAction? onSelectLocalEmailDraftAction;
  final OnEditLocalEmailDraftAction? onEditLocalEmailDraftAction;
  final OnSaveAsDraftLocalEmailDraftAction? onSaveAsDraftLocalEmailDraftAction;
  final OnDiscardLocalEmailDraftAction? onDiscardLocalEmailDraftAction;

  const LocalEmailDraftItemWidget({
    super.key,
    required this.draftLocal,
    required this.imagePaths,
    required this.isOldest,
    this.onSelectLocalEmailDraftAction,
    this.onEditLocalEmailDraftAction,
    this.onSaveAsDraftLocalEmailDraftAction,
    this.onDiscardLocalEmailDraftAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => onSelectLocalEmailDraftAction?.call(draftLocal),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: 12,
            end: 12,
            top: 12,
            bottom: isOldest ? 12 : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EmailAvatarBuilder(
                avatarText: draftLocal.avatarText,
                avatarColors: draftLocal.avatarColors,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          draftLocal.firstRecipientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black),
                        ),
                      ),
                      if (draftLocal.isMarkAsImportant == true)
                        SvgPicture.asset(
                          imagePaths.icMarkAsImportant,
                          width: 20,
                          height: 20,
                          fit: BoxFit.fill,
                          colorFilter: AppColor.steelGray200.asFilter(),
                        ),
                      if (draftLocal.hasAttachment)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          child: SvgPicture.asset(
                            imagePaths.icAttachment,
                            width: 16,
                            height: 16,
                            colorFilter: AppColor.steelGray200.asFilter(),
                            fit: BoxFit.fill,
                          ),
                        ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.only(end: 4, start: 8),
                        child: Text(
                          draftLocal.getSavedTime(
                              Localizations.localeOf(context).toLanguageTag()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColor.steelGray400),
                        ),
                      ),
                    ]),
                    if (draftLocal.emailSubject.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          draftLocal.emailSubject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColor.steelGray400),
                        ),
                      ),
                    if (draftLocal.emailContent.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          draftLocal.emailContent,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColor.steelGray400),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                          child: TMailButtonWidget(
                            text: AppLocalizations.of(context).edit,
                            textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColor.primaryColor, fontSize: 12),
                            maxLines: 1,
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                            margin: const EdgeInsetsDirectional.only(end: 8),
                            onTapActionCallback: () => onEditLocalEmailDraftAction?.call(draftLocal),
                          ),
                        ),
                        Flexible(
                          child: TMailButtonWidget(
                            text: AppLocalizations.of(context).saveAsDraft,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.black, fontSize: 12),
                            maxLines: 1,
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                            margin: const EdgeInsetsDirectional.only(end: 8),
                            onTapActionCallback: () => onSaveAsDraftLocalEmailDraftAction?.call(draftLocal),
                          ),
                        ),
                        Flexible(
                          child: TMailButtonWidget(
                            text: AppLocalizations.of(context).discard,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColor.colorActionDeleteConfirmDialog, fontSize: 12),
                            maxLines: 1,
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                            margin: const EdgeInsetsDirectional.only(end: 8),
                            onTapActionCallback: () => onDiscardLocalEmailDraftAction?.call(draftLocal),
                          ),
                        ),
                      ],
                    ),
                    if (!isOldest)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Divider(color: AppColor.colorDivider, height: 0.5,)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
