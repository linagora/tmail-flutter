Closes #4877

## Problem
Opening a password-protected PDF showed « Impossible de prévisualiser le PDF — PdfException: No password supplied by PasswordProvider. ». pdfrx supports a `PasswordProvider`, but `TwakePdfPreviewer` (twake-previewer-flutter) does not expose one.

## Changes
- `PasswordAwarePdfPreviewer`: same layout as `TwakePdfPreviewer`, built from the upstream building blocks (`PreviewerTemplateWidget`, `TopBarWidget`, `PdfPaginationWidget`, `PdfPreviewer`). It only replaces the document source with one that carries a `passwordProvider`. The upstream zoom, layout and overlay params are kept as they are.
- `PDFViewer` asks for the password with `EditTextDialogBuilder`. The field is obscured. pdfrx calls the provider again after each wrong password, and the dialog then shows a localized "Incorrect password" error.
- Cancelling the dialog shows a localized message in the error banner instead of the raw `PdfException`. The download button stays available.
- `EditTextDialogBuilder` gets two new optional params, `obscureText` and `initialError`. Defaults are unchanged, so the rename-folder dialog behaves the same.
- New strings in en/fr/messages arb files. `pdfrx` (already resolved at 2.1.5 through twake_previewer_flutter) is now declared as a direct dependency.

## Notes
- A cleaner long-term fix is to add a `passwordProvider` parameter to `TwakePdfPreviewer` upstream. Once that exists, `PasswordAwarePdfPreviewer` can be removed.
- Not validated: Flutter SDK was not available in the environment, so `flutter analyze` and the new widget test (`core/test/presentation/views/dialog/edit_text_dialog_builder_test.dart`) were **not run**. Manual testing with an encrypted PDF was not done either.

---
*Generated automatically*
