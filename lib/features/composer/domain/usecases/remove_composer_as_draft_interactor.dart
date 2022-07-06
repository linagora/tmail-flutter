import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';

class RemoveComposerAsDraftsInteractor {
  final ComposerRepository composerRepository;

  RemoveComposerAsDraftsInteractor(this.composerRepository);

  Future<void> execute() async {
    return composerRepository.deleteDraftComposer();
  }
}