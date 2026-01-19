#
# Custom plugin loader that excludes unsupported plugins.
# This replaces the generated_plugins.cmake include to filter out
# firebase_core which doesn't support Windows desktop builds.
#

# Plugins to exclude from Windows builds (Firebase doesn't support Windows desktop)
set(EXCLUDED_PLUGINS
  firebase_core
)

message(STATUS "Loading Flutter plugins (excluding: ${EXCLUDED_PLUGINS})")

# Define the plugin lists (copied from generated_plugins.cmake structure)
list(APPEND FLUTTER_PLUGIN_LIST
  app_links
  connectivity_plus
  desktop_drop
  desktop_webview_window
  flutter_inappwebview_windows
  flutter_secure_storage_windows
  permission_handler_windows
  printing
  sentry_flutter
  share_plus
  url_launcher_windows
  window_to_front
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
  jni
  pdfrx
)

set(PLUGIN_BUNDLED_LIBRARIES)

foreach(plugin ${FLUTTER_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${plugin}/windows plugins/${plugin})
  target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:${plugin}_plugin>)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${plugin}_bundled_libraries})
endforeach(plugin)

foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${ffi_plugin}/windows plugins/${ffi_plugin})
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${ffi_plugin}_bundled_libraries})
endforeach(ffi_plugin)

message(STATUS "Loaded ${CMAKE_CURRENT_LIST_LENGTH} plugins for Windows build")
