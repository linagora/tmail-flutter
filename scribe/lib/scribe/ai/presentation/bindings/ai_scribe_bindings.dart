import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:scribe/scribe/ai/data/datasource/ai_datasource.dart';
import 'package:scribe/scribe/ai/data/datasource_impl/ai_datasource_impl.dart';
import 'package:scribe/scribe/ai/data/network/ai_api.dart';
import 'package:scribe/scribe/ai/data/repository/ai_repository_impl.dart';
import 'package:scribe/scribe/ai/domain/repository/ai_scribe_repository.dart';
import 'package:scribe/scribe/ai/domain/usecases/generate_ai_text_interactor.dart';

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
