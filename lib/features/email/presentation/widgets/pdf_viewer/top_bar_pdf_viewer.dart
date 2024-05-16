import 'package:flutter/material.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TopBarPDFViewer extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback? downloadAction;
  final VoidCallback? printAction;
  final VoidCallback? closeAction;

  const TopBarPDFViewer({
    super.key,
    required this.attachment,
    this.downloadAction,
    this.printAction,
    this.closeAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 52,
      color: Colors.black.withOpacity(0.3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: closeAction ?? Navigator.maybeOf(context)?.pop,
            padding: const EdgeInsets.all(8),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
            focusColor: Colors.black.withOpacity(0.3),
            hoverColor: Colors.black.withOpacity(0.3),
            tooltip: AppLocalizations.of(context).close,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              attachment.generateFileName(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontSize: 17,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (printAction != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: IconButton(
                onPressed: printAction,
                padding: const EdgeInsets.all(8),
                icon: const Icon(
                  Icons.print,
                  color: Colors.white,
                  size: 24,
                ),
                focusColor: Colors.black.withOpacity(0.3),
                hoverColor: Colors.black.withOpacity(0.3),
                tooltip: AppLocalizations.of(context).print,
              ),
            ),
          if (downloadAction != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: IconButton(
                onPressed: downloadAction,
                padding: const EdgeInsets.all(8),
                icon: const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 24,
                ),
                focusColor: Colors.black.withOpacity(0.3),
                hoverColor: Colors.black.withOpacity(0.3),
                tooltip: AppLocalizations.of(context).download,
              ),
            )
        ],
      ),
    );
  }
}
