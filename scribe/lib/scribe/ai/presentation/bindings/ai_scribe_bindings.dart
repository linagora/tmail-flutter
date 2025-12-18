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
    Get.lazyPut<AIApi>(() => AIApi(Get.find<DioClient>(), aiEndpoint));
  }

  void _bindingsDataSourceImpl() {
    Get.lazyPut<AIDataSourceImpl>(() => AIDataSourceImpl(Get.find<AIApi>()));
  }

  void _bindingsDataSource() {
    Get.lazyPut<AIDataSource>(() => Get.find<AIDataSourceImpl>());
  }

  void _bindingsRepositoryImpl() {
    Get.lazyPut<AIScribeRepositoryImpl>(
      () => AIScribeRepositoryImpl(Get.find<AIDataSource>()),
    );
  }

  void _bindingsRepository() {
    Get.lazyPut<AIScribeRepository>(() => Get.find<AIScribeRepositoryImpl>());
  }

  void _bindingsInteractor() {
    Get.lazyPut<GenerateAITextInteractor>(
      () => GenerateAITextInteractor(Get.find<AIScribeRepository>()),
    );
  }
}
