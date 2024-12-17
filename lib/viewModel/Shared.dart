import 'package:get/get.dart';
import 'package:my_vocabulary/repository/getDataFromDb.dart';

class GameStateController extends GetxController {
  final VocabularyRepository _repository = VocabularyRepository();
  var isGameInProgress = false.obs;

  Future<bool> checkData() async{
    return  await _repository.hasVocabulary() ;
  }
}
