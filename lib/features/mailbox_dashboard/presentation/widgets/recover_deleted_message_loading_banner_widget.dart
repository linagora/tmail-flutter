import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_restored_deleted_message_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/restore_deleted_message_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RecoverDeletedMessageLoadingBannerWidget extends StatelessWidget {
  final Either<Failure, Success> viewState;
  final Widget horizontalLoadingWidget;
  final ResponsiveUtils responsiveUtils;

  const RecoverDeletedMessageLoadingBannerWidget({
    super.key,
    required this.viewState,
    required this.horizontalLoadingWidget,
    required this.responsiveUtils,
  });

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) {
        log('RecoverDeletedMessageLoadingBannerWidget:: failure $failure');
        return const SizedBox.shrink();
      
      },
      (success) {
        if (success is RestoreDeletedMessageLoading 
          || success is RestoreDeletedMessageSuccess 
          || success is GetRestoredDeletedMessageLoading
        ) {
          return Padding(
            padding: EdgeInsets.only(
              top: responsiveUtils.isDesktop(context) ? 16 : 0,
              right: 16,
              bottom: responsiveUtils.isDesktop(context) ? 0 : 16,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: AppColor.colorBorderBodyThread,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).bannerProgressingRecoveryMessage,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  horizontalLoadingWidget
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }
}