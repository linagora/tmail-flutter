import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart' as tmail;

final searchViewOpenProvider = StreamProvider.autoDispose<bool>((ref) {
  final controller = Get.find<tmail.SearchController>();
  return controller.isAdvancedSearchViewOpen.stream;
});
