import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:scribe/scribe/ai/data/datasource/ai_datasource.dart';
import 'package:scribe/scribe/ai/data/datasource_impl/ai_datasource_impl.dart';
import 'package:scribe/scribe/ai/data/repository/ai_repository_impl.dart';
import 'package:scribe/scribe/ai/domain/repository/ai_scribe_repository.dart';
import 'package:scribe/scribe/ai/domain/usecases/generate_ai_text_interactor.dart';

class AIScribeBindings extends Bindings {
  @override
  void dependencies() {
    _bindingsDataSourceImpl();
    _bindingsDataSource();
    _bindingsRepositoryImpl();
    _bindingsRepository();
    _bindingsInteractor();
  }

  void _bindingsDataSourceImpl() {
    Get.lazyPut<AIDataSourceImpl>(() => AIDataSourceImpl(
      dio: Get.find<Dio>(),
    ));
  }

  void _bindingsDataSource() {
    Get.lazyPut<AIDataSource>(() => Get.find<AIDataSourceImpl>());
  }

  void _bindingsRepositoryImpl() {
    Get.lazyPut<AIScribeRepositoryImpl>(() => AIScribeRepositoryImpl(
      Get.find<AIDataSource>(),
    ));
  }

  void _bindingsRepository() {
    Get.lazyPut<AIScribeRepository>(() => Get.find<AIScribeRepositoryImpl>());
  }

  void _bindingsInteractor() {
    Get.lazyPut<GenerateAITextInteractor>(() => GenerateAITextInteractor(
      Get.find<AIScribeRepository>(),
    ));
  }
}
