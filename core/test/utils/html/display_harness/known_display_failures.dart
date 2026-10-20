/// Display gaps the rules found that production does not fix yet, by test
/// name; each fix PR deletes its entries so the case runs again.
library;

const _iosNoResponsiveScript =
    'iOS EML previewer has no image normalize or responsive script';
const _webNoReflow =
    'web does not reflow wide tables or fit a fixed-width wrapper div';

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
};
