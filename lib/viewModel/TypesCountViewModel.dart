import 'package:get/get.dart';
import '../repository/getDataFromDb.dart';
import '../model/typesCount.dart';

class MainScreenViewModel extends GetxController {
  final VocabularyRepository _repository = VocabularyRepository();
  final Rx<VocabularyCounts> counts = VocabularyCounts(
    nouns: 0,
    verbs: 0,
    adjectives: 0,
    adverbs: 0,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    final countsMap = await _repository.fetchCounts();
    counts.value = VocabularyCounts.fromMap(countsMap);
  }
}
