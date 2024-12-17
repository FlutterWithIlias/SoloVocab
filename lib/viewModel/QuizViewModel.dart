import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:my_vocabulary/viewModel/Shared.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/vocabulary.dart';
import '../repository/getDataFromDb.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class QuizViewModel extends GetxController {
  final VocabularyRepository _repository = VocabularyRepository();
  final FlutterTts _flutterTts = FlutterTts();
  final GameStateController gameStateController = Get.find<GameStateController>();
  
  var vocabularyList = <Vocabulary>[].obs;
  var currentQuestionIndex = 0.obs;
  var progress = 0.0.obs;
  var isCorrectAnswer = false.obs;
  var starting = 3.obs;
  var isGameStarted = false.obs;
  var isNextQuestion = false.obs;
  var subQuestionCurrentValue = ''.obs;
  int subQuestionState = 0;
  var endGame = false.obs;
  var GameWon = false.obs;
  var spokenText = ''.obs;
  var soloStart = false.obs ; 

  // Lock-related variables
  var isGameLocked = false.obs; // Indicates if the game is locked
  var lockRemainingTime = ''.obs; // Remaining lock time for countdown

  @override
  void onInit() {
    super.onInit();
     checkLockStatus();
      if(isGameLocked.value && endGame.value){
      gameStateController.isGameInProgress.value = true ; 
      }
     // Check lock status at startup
  }


  void fetchVocabulary() async {
    try {
      List<Vocabulary> vocabulary = await _repository.getAllVocabulary();
      vocabularyList.assignAll(vocabulary);
      subQuestionCurrentValue.value = vocabularyList.first.word;
      speakWord("Starting");
      spokenText.value= "1-Listening\n2-Translation\n3-Type" ; 
    } catch (e) {
      print("Error fetching vocabulary: $e");
    }
  }

  Vocabulary get currentWord => vocabularyList[currentQuestionIndex.value];

  void initializeTts() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(0.5);
    _flutterTts.setSpeechRate(0.5);
  }

  Future<void> speakWord(String word) async {
    await _flutterTts.speak(word);
  }

  void checkAnswer(String answer) {
    if (answer.toLowerCase() == subQuestionCurrentValue.toLowerCase()) {
      isCorrectAnswer.value = true;
      subQuestionState++;
      if (subQuestionState < 3) {
        startProgressTimer();
        moveToNextSubQuestion();
      } else {
        isNextQuestion.value = true;
        moveToNextQuestion();
      }
    } else {
      lockRemainingTime.value = '';
      gameStateController.isGameInProgress.value = false ; 
      endGame.value = true;// Lock the game after losing
      isCorrectAnswer.value = false; 
    }
  }

  void moveToNextSubQuestion() {
    switch (subQuestionState) {
      case 1:
        subQuestionCurrentValue.value = currentWord.translation;
        speakWord("Write the correct translation of ${currentWord.word}");
        spokenText.value = "Write the correct translation of ${currentWord.word}" ; 
        break;
      case 2:
        subQuestionCurrentValue.value = currentWord.type;
        speakWord("Write the correct type of ${currentWord.word} ");
         spokenText.value = "Write the correct type of ${currentWord.word} " ; 
        break;     
      default:
        subQuestionState = 0;
        subQuestionCurrentValue.value = currentWord.word;
        spokenText.value= "Listen carefully and write the correct word ${currentWord.word}" ; 
        speakWord(spokenText.value);
        Future.delayed(Duration(seconds: 3), () {
              speakWord(currentWord.word);
  }); 
         
    }
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex.value < vocabularyList.length - 1) {
      currentQuestionIndex.value++;
      subQuestionState = 0;
      subQuestionCurrentValue.value = currentWord.word;
    } else { // Reset to start
      gameStateController.isGameInProgress.value = false ; 
      GameWon.value = true;
    }
  }

  ///////////timer
  void startProgressTimer() {
    const int totalDuration = 13000; // Total time in milliseconds (5 seconds)
    const int interval = 100; // Timer tick interval in milliseconds
    int elapsed = 0;
    double percent;

    Timer.periodic(Duration(milliseconds: interval), (timer) {
      elapsed += interval;
      percent = elapsed / totalDuration;

      // Update the progress (clamped to a maximum of 1.0)
      progress.value = percent;
      if (elapsed >= totalDuration || endGame.value) {
        // endGame.value = true; 
        lockRemainingTime.value = '';
        gameStateController.isGameInProgress.value = false ; 
        lockGame(); // Lock the game if time runs out
        timer.cancel();
      }

      if (isCorrectAnswer.value) {
        isCorrectAnswer.value = false;
        timer.cancel();
      }
    });
  }

  void startingTimer() {
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      starting.value--;
      if (starting == 0) {
        spokenText.value= "Listen carefully and write the correct word" ; 
          speakWord("Listen carefully and write the correct word" );
        isGameStarted.value = true;
        timer.cancel();
        Future.delayed(Duration(seconds: 3), () {
          speakWord(currentWord.word);
  }); 
        startProgressTimer();
      }
    });

  }
    Future<void> lockGame() async {
    endGame.value=true ; 
    isGameLocked.value = true;
    final prefs = await SharedPreferences.getInstance();
    final lockUntil = DateTime.now().add(Duration(minutes: 1  )).millisecondsSinceEpoch;
    prefs.setInt('lockUntil', lockUntil);
    updateLockCountdown();
  }

  void checkLockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lockUntil = prefs.getInt('lockUntil') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lockUntil > now) {
      isGameLocked.value = true;
      updateLockCountdown();
    } else {
      isGameLocked.value = false;
      prefs.remove('lockUntil');
      startGame();
    }
  }
  void updateLockCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      final lockUntil = prefs.getInt('lockUntil') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (lockUntil > now) {
        final remaining = Duration(milliseconds: lockUntil - now);
        lockRemainingTime.value =
            "${remaining.inHours}:${(remaining.inMinutes % 60).toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}";
      } else {
        timer.cancel();
        endGame.value=true ;
        isGameLocked.value = false;
        resetValues();
        prefs.remove('lockUntil');
      }
    });
  }

  void resetValues(){
   currentQuestionIndex.value = 0;
   progress.value  = 0.0;
   isCorrectAnswer.value  = false;
   starting.value  = 3;
   isGameStarted.value  = false;
   isNextQuestion.value  = false;
   subQuestionCurrentValue.value  = '';
   subQuestionState = 0;
  //  endGame.value  = false;
   GameWon.value  = false;
   spokenText.value  = '';
   soloStart.value = false ; 
  }

  void startGame(){
    fetchVocabulary();
    initializeTts();
    startingTimer();
  }
}


