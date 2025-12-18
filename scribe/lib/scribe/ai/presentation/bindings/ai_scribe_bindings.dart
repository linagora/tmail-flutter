import 'package:core/data/network/dio_client.dart';
import 'package:get/get.dart';
import 'package:scribe/scribe.dart';
import 'package:scribe/scribe/ai/data/datasource_impl/ai_datasource_impl.dart';
import 'package:scribe/scribe/ai/data/network/ai_api.dart';

class AIScribeBindings extends Bindings {
  final String aiEndpoint;

  AIScribeBindings(this.aiEndpoint);

  @override
  void dependencies() {
    _bindingsAPI();
    _bindingsDataSourceImpl();
    _bindingsDataSource();
    _bindingsRepositoryImpl();
    _bindingsRepository();
    _bindingsInteractor();
  }

  void _bindingsAPI() {
    Get.put(AIApi(Get.find<DioClient>(), aiEndpoint));
  }

  void _bindingsDataSourceImpl() {
    Get.put(AIDataSourceImpl(Get.find<AIApi>()));
  }

  void _bindingsDataSource() {
    Get.put<AIDataSource>(Get.find<AIDataSourceImpl>());
  }

  void _bindingsRepositoryImpl() {
    Get.put(AIScribeRepositoryImpl(Get.find<AIDataSource>()));
  }

  void _bindingsRepository() {
    Get.put<AIScribeRepository>(Get.find<AIScribeRepositoryImpl>());
  }

  void _bindingsInteractor() {
    Get.put(GenerateAITextInteractor(Get.find<AIScribeRepository>()));
  }
}
