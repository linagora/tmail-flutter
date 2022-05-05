library core;

// Extensions
export 'presentation/extensions/color_extension.dart';
export 'presentation/extensions/url_extension.dart';
export 'presentation/extensions/capitalize_extension.dart';
export 'presentation/extensions/list_extensions.dart';
export 'domain/extensions/datetime_extension.dart';
export 'presentation/extensions/html_extension.dart';
export 'presentation/extensions/compare_string_extension.dart';
export 'presentation/extensions/compare_list_extensions.dart';

// Exceptions
export 'domain/exceptions/download_file_exception.dart';
export 'data/extensions/options_extensions.dart';

// Utils
export 'presentation/utils/theme_utils.dart';
export 'presentation/utils/responsive_utils.dart';
export 'presentation/utils/keyboard_utils.dart';
export 'presentation/utils/style_utils.dart';
export 'presentation/utils/app_toast.dart';
export 'presentation/utils/html_transformer/html_template.dart';
export 'presentation/utils/html_transformer/html_transform.dart';
export 'presentation/utils/html_transformer/transform_configuration.dart';
export 'presentation/utils/html_transformer/dom/add_tooltip_link_transformers.dart';
export 'data/utils/device_manager.dart';
export 'utils/app_logger.dart';
export 'utils/benchmark.dart';
export 'utils/fps_manager.dart';
export 'utils/build_utils.dart';

// Views
export 'presentation/views/text/slogan_builder.dart';
export 'presentation/views/text/text_field_builder.dart';
export 'presentation/views/text/input_decoration_builder.dart';
export 'presentation/views/text/text_builder.dart';
export 'presentation/views/text/rich_text_builder.dart';
export 'presentation/views/responsive/responsive_widget.dart';
export 'presentation/views/list/tree_view.dart';
export 'presentation/views/button/button_builder.dart';
export 'presentation/views/button/icon_button_web.dart';
export 'presentation/views/image/avatar_builder.dart';
export 'presentation/views/list/sliver_grid_delegate_fixed_height.dart';
export 'presentation/views/image/icon_builder.dart';
export 'presentation/views/context_menu/context_menu_action_builder.dart';
export 'presentation/views/context_menu/context_menu_builder.dart';
export 'presentation/views/context_menu/context_menu_header_builder.dart';
export 'presentation/views/context_menu/simple_context_menu_action_builder.dart';
export 'presentation/views/dialog/downloading_file_dialog_builder.dart';
export 'presentation/views/dialog/confirmation_dialog_builder.dart';
export 'presentation/views/dialog/edit_text_dialog_builder.dart';
export 'presentation/views/background/background_widget_builder.dart';
export 'presentation/views/html_viewer/html_content_viewer_widget.dart';
export 'presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
export 'presentation/views/html_viewer/html_viewer_controller_for_web.dart';
export 'presentation/views/floating_button/scrolling_floating_button_animated.dart';
export 'presentation/views/bottom_popup/cupertino_action_sheet_action_builder.dart';
export 'presentation/views/bottom_popup/cupertino_action_sheet_builder.dart';
export 'presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
export 'presentation/views/modal_sheets/edit_text_modal_sheet_builder.dart';
export 'presentation/views/search/search_bar_view.dart';
export 'presentation/views/popup_menu/popup_menu_item_widget.dart';
export 'presentation/views/tab_bar/custom_tab_indicator.dart';

// Resources
export 'presentation/resources/assets_paths.dart';
export 'presentation/resources/image_paths.dart';

// Constants
export 'presentation/constants/constants_ui.dart';
export 'data/constants/constant.dart';

// Network
export 'data/network/config/authorization_interceptors.dart';
export 'data/network/config/dynamic_url_interceptors.dart';
export 'data/network/config/endpoint.dart';
export 'data/network/config/service_path.dart';
export 'data/network/dio_client.dart';
export 'data/network/download/download_client.dart';
export 'data/network/download/download_manager.dart';

// State
export 'presentation/state/success.dart';
export 'presentation/state/failure.dart';
export 'presentation/state/app_state.dart';

// Local
export 'data/local/config/database_config.dart';
export 'data/local/config/email_address_table.dart';
export 'data/local/database_client.dart';
export 'data/local/database_manager.dart';

// Model
export 'data/model/data_source_type.dart';