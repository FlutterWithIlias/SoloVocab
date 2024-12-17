import 'package:get/get.dart';
import 'package:my_vocabulary/viewModel/QuizViewModel.dart';
import 'package:my_vocabulary/viewModel/Shared.dart';
import 'package:my_vocabulary/viewModel/TypesCountViewModel.dart';
import 'package:my_vocabulary/viewModel/vocabulary_viewmodel.dart';


class VocabularyBinding extends Bindings {
  @override
  void dependencies() {
    // Immediate initialization of VocabularyViewModel using Get.put
    Get.lazyPut<GameStateController>(() => GameStateController());
    Get.lazyPut<QuizViewModel>(() => QuizViewModel());
    Get.lazyPut<MainScreenViewModel>(() => MainScreenViewModel());
    Get.put<VocabularyViewModel>(VocabularyViewModel());
  }
}
