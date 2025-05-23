import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

typedef LoadMoreIndex = int;
typedef LoadMoreCount = int;
typedef LoadMoreSegments = Map<LoadMoreIndex, LoadMoreCount>;

extension ThreadDetailLoadMoreSegments on ThreadDetailController {
  LoadMoreSegments get loadMoreSegments {
    final loadMoreInfo = <LoadMoreIndex, LoadMoreCount>{};
    int currentIndex = 0;
    final emailIds = emailIdsPresentation.values.toList();

    while (currentIndex < emailIdsPresentation.length) {
      if (emailIds[currentIndex] == null) {
        // Found start of a null segment
        int segmentIndex = currentIndex;
        int segmentCount = 0;
        
        // Count consecutive nulls
        while (currentIndex < emailIdsPresentation.length &&
              emailIds[currentIndex] == null) {
          segmentCount++;
          currentIndex++;
        }
        
        loadMoreInfo[segmentIndex] = segmentCount;
      } else {
        currentIndex++;
      }
    }
    return loadMoreInfo;
  }
}