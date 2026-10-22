/// Display gaps the rules found that production does not fix yet, by test
/// name; each fix PR deletes its entries so the case runs again.
library;

const _iosNoResponsiveScript =
    'iOS EML previewer has no image normalize or responsive script';
const _webNoReflow =
    'web does not reflow wide tables or fit a fixed-width wrapper div';

const _attachmentNoResponsiveScript =
    'HtmlAttachmentPreviewer has no responsive table transformer or mobile responsive script';
const _printNoReflow =
    'print document has no responsive script; wide content runs past the page';
const _printNoDir = 'print document has no body dir';

const knownDisplayFailures = <String, String>{
  'expect_checks/auto_scale_reflow_table @ios 296px': _iosNoResponsiveScript,
  'expect_checks/auto_scale_reflow_table @ios 336px': _iosNoResponsiveScript,
  'expect_checks/auto_scale_reflow_table @ios 390px': _iosNoResponsiveScript,
  'expect_checks/auto_scale_reflow_table @web 524px': _webNoReflow,
  'expect_checks/auto_scale_reflow_table @web 760px': _webNoReflow,
  'expect_checks/auto_scale_table @ios 296px': _iosNoResponsiveScript,
  'expect_checks/auto_scale_table @ios 336px': _iosNoResponsiveScript,
  'expect_checks/auto_scale_table @ios 390px': _iosNoResponsiveScript,
  'expect_checks/auto_scale_table @web 524px': _webNoReflow,
  'expect_checks/auto_scale_table @web 760px': _webNoReflow,
  'expect_checks/auto_scale_zoom @ios 296px': _iosNoResponsiveScript,
  'expect_checks/auto_scale_zoom @ios 336px': _iosNoResponsiveScript,
  'expect_checks/auto_scale_zoom @ios 390px': _iosNoResponsiveScript,
  'expect_checks/auto_scale_zoom @web 524px': _webNoReflow,
  'expect_checks/auto_scale_zoom @web 760px': _webNoReflow,
  'expect_checks/quote_toggle_wide @ios 296px': _iosNoResponsiveScript,
  'expect_checks/quote_toggle_wide @ios 336px': _iosNoResponsiveScript,
  'expect_checks/quote_toggle_wide @ios 390px': _iosNoResponsiveScript,
  'expect_checks/quote_toggle_wide @web 524px': _webNoReflow,
  'expect_checks/quote_toggle_wide @web 760px': _webNoReflow,
  'layout_stress/wide_image @ios 296px': _iosNoResponsiveScript,
  'layout_stress/wide_image @ios 336px': _iosNoResponsiveScript,
  'layout_stress/wide_image @ios 390px': _iosNoResponsiveScript,
  'layout_stress/wide_table @web 1000px': _webNoReflow,
  'layout_stress/wide_table @web 760px': _webNoReflow,
  'newsletter_builders/mailchimp @ios 296px': _iosNoResponsiveScript,
  'newsletter_builders/mailchimp @ios 336px': _iosNoResponsiveScript,
  'newsletter_builders/mailchimp @ios 390px': _iosNoResponsiveScript,
  'expect_checks/auto_scale_reflow_table @attachment 320px': _attachmentNoResponsiveScript,
  'expect_checks/auto_scale_reflow_table @attachment 360px': _attachmentNoResponsiveScript,
  'expect_checks/auto_scale_reflow_table @attachment 414px': _attachmentNoResponsiveScript,
  'expect_checks/auto_scale_reflow_table @attachment 614px': _attachmentNoResponsiveScript,
  'expect_checks/auto_scale_table @attachment 320px': _attachmentNoResponsiveScript,
  'expect_checks/auto_scale_table @attachment 360px': _attachmentNoResponsiveScript,
  'expect_checks/auto_scale_table @attachment 414px': _attachmentNoResponsiveScript,
  'expect_checks/auto_scale_table @attachment 614px': _attachmentNoResponsiveScript,
  'expect_checks/auto_scale_zoom @attachment 320px': _attachmentNoResponsiveScript,
  'expect_checks/auto_scale_zoom @attachment 360px': _attachmentNoResponsiveScript,
  'expect_checks/auto_scale_zoom @attachment 414px': _attachmentNoResponsiveScript,
  'expect_checks/auto_scale_zoom @attachment 614px': _attachmentNoResponsiveScript,
  'expect_checks/quote_toggle_wide @attachment 320px': _attachmentNoResponsiveScript,
  'expect_checks/quote_toggle_wide @attachment 360px': _attachmentNoResponsiveScript,
  'expect_checks/quote_toggle_wide @attachment 414px': _attachmentNoResponsiveScript,
  'expect_checks/quote_toggle_wide @attachment 614px': _attachmentNoResponsiveScript,
  'layout_stress/long_url_cell @attachment 320px': _attachmentNoResponsiveScript,
  'layout_stress/long_url_cell @attachment 360px': _attachmentNoResponsiveScript,
  'layout_stress/wide_table @attachment 614px': _attachmentNoResponsiveScript,
  'newsletter_builders/cerberus_media @attachment 614px': _attachmentNoResponsiveScript,
  'newsletter_builders/mailchimp @attachment 614px': _attachmentNoResponsiveScript,
  'scripts_languages/rtl_arabic @print 794px': _printNoDir,
  'expect_checks/auto_scale_reflow_table @print 794px': _printNoReflow,
  'expect_checks/auto_scale_table @print 794px': _printNoReflow,
  'expect_checks/auto_scale_zoom @print 794px': _printNoReflow,
  'expect_checks/quote_toggle_wide @print 794px': _printNoReflow,
  'layout_stress/wide_image @print 794px': _printNoReflow,
  'layout_stress/wide_table @print 794px': _printNoReflow,
};
