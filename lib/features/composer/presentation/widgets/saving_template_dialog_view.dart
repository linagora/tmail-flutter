import 'dart:async';
import 'dart:math';

import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/save_template_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/update_template_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/save_template_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SavingTemplateDialogView extends StatefulWidget {

  final CreateEmailRequest createEmailRequest;
  final SaveTemplateEmailInteractor saveTemplateEmailInteractor;
  final CreateNewMailboxRequest? createNewMailboxRequest;
  final CancelToken? cancelToken;
  final void Function(CancelToken? cancelToken)? onCancel;

  const SavingTemplateDialogView({
    super.key,
    required this.createEmailRequest,
    required this.saveTemplateEmailInteractor,
    required this.createNewMailboxRequest,
    this.cancelToken,
    this.onCancel,
  });

  @override
  State<SavingTemplateDialogView> createState() => _SavingTemplateDialogViewState();
}

class _SavingTemplateDialogViewState extends State<SavingTemplateDialogView> {
  StreamSubscription? _streamSubscription;
  final ValueNotifier<Either<Failure, Success>?> _viewStateNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _streamSubscription = widget.saveTemplateEmailInteractor
      .execute(
        createEmailRequest: widget.createEmailRequest,
        createNewMailboxRequest: widget.createNewMailboxRequest,
        cancelToken: widget.cancelToken
      )
      .listen(_handleDataStream, onError: _handleErrorStream);
  }

  void _handleDataStream(Either<Failure, Success> newState) {
    _viewStateNotifier.value = newState;

    newState.fold(
      (failure) {
        if (failure is SaveTemplateEmailFailure ||
            failure is UpdateTemplateEmailFailure ||
            failure is GenerateEmailFailure) {
          popBack(result: failure);
        }
      },
      (success) {
        if (success is SaveTemplateEmailSuccess || success is UpdateTemplateEmailSuccess) {
          popBack(result: success);
        }
      }
    );
  }

  void _handleErrorStream(Object error, StackTrace stackTrace) {
    logError('SavingTemplateDialogView::_handleErrorStream: Exception = $error');
    popBack(result: SaveTemplateEmailFailure(exception: error));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      alignment: Alignment.center,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Colors.white,
        ),
        width: min(context.width, 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: AppColor.colorItemSelected,
              ),
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context).savingTemplate.capitalizeFirstEach,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17
                ),
              ),
            ),
            const Divider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 12, bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '${AppLocalizations.of(context).status}:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: _viewStateNotifier,
                          builder: (context, value, child) {
                            if (value == null) {
                              return child!;
                            }

                            return value.fold(
                              (failure) => child!,
                              (success) {
                                return Text(
                                  '${_getStatusMessage(success)}...',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColor.labelColor,
                                    fontSize: 14
                                  ),
                                );
                              }
                            );
                          },
                          child: Text(
                            '...',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColor.labelColor,
                              fontSize: 14
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 4, bottom: 16),
                  child: Row(
                    children: [
                      Text(
                        '${AppLocalizations.of(context).progress}:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          color: Colors.white.withOpacity(0.6),
                          backgroundColor: AppColor.primaryColor,
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                        ),
                      )
                    ],
                  ),
                ),
                if (widget.onCancel != null)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TMailButtonWidget.fromText(
                      text: AppLocalizations.of(context).cancel,
                      textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.black87,
                        fontSize: 15
                      ),
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 8),
                      margin: const EdgeInsetsDirectional.only(start: 12, end: 12, bottom: 16),
                      onTapActionCallback: () {
                        _viewStateNotifier.value = Left(SaveTemplateEmailFailure());
                        widget.onCancel!(widget.cancelToken);
                      },
                    ),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(Success success) {
    if (success is GenerateEmailLoading) {
      return AppLocalizations.of(context).creatingMessage;
    } else {
      return AppLocalizations.of(context).savingMessageToTemplateFolder;
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _viewStateNotifier.dispose();
    super.dispose();
  }
}
