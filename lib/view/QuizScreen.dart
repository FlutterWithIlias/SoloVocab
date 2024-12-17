import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_vocabulary/main.dart';
import 'package:my_vocabulary/view/MainScreenBinding.dart';
import 'package:my_vocabulary/viewModel/QuizViewModel.dart';
import 'package:my_vocabulary/viewModel/Shared.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';



class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizViewModel viewModel = Get.find<QuizViewModel>();
   final GameStateController gameStateController = Get.find<GameStateController>();
   @override
  // void initState() {
  //   super.initState();
  //   viewModel.speakWord(viewModel.currentWord.word);
  // }
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); 
  bool isButtonEnabled = true;
  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Makes the AppBar transparent // Removes the shadow
        title: 
        Obx((){
          return         
         Text(
          "Word:  ${viewModel.currentQuestionIndex.value+1}/${viewModel.vocabularyList.length}",
          style: TextStyle(fontFamily: 'Raleway',color: Colors.white,fontSize: 25),
        ); }),
        centerTitle: true,
      ),
      body: Container(
        height: Get.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, // Start of the gradient
            end: Alignment.bottomCenter, // End of the gradient
            colors: [
              Color.fromARGB(255, 142, 45, 234),
              Color.fromARGB(255, 199, 163, 245),
              Color.fromARGB(255, 231, 224, 240), // Start with white // End with a near-purple color
            ],
          ),
        ),
   child: 
   
   Obx((){

    if(viewModel.endGame.value || viewModel.isGameLocked.value ){
      return Container(
    width: Get.width,
           margin: EdgeInsets.symmetric(
        horizontal: Get.width * 0.05,
        vertical: Get.height * 0.25,
      ),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(        color: Colors.black.withOpacity(0.2), // Shadow color
        spreadRadius: 2, // Spread radius
        blurRadius: 10, // Blur radius
        offset: Offset(0, 4),)
    ]// Add borderRadius
  ),
  child: Column(
    children: [
      Container( 
        height: Get.height*0.3,
        width: Get.width*0.60,
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage('assets/endgameLose.png'),
        fit: BoxFit.contain,
    ),
  ),
),
SizedBox(height: Get.height * 0.05,),
Text("Good Luck for the next time!",style: TextStyle(fontWeight: FontWeight.bold,fontSize: Get.width * 0.06),),
SizedBox(height: Get.height * 0.02,),
displayRemaningTime(viewModel.lockRemainingTime.value),
    ],
  ),
   );
    }
else if(viewModel.GameWon.value){
   return   Container(
    width: Get.width,
    margin:  EdgeInsets.symmetric(
        horizontal: Get.width * 0.05,
        vertical: Get.height * 0.25,
      ),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(        color: Colors.black.withOpacity(0.2), // Shadow color
        spreadRadius: 2, // Spread radius
        blurRadius: 10, // Blur radius
        offset: Offset(0, 4),)
    ]// Add borderRadius
  ),
  child: Column(
    children: [
      Container( 
        height: Get.height*0.3,
        width: Get.width*0.60,
        child: Lottie.asset(
            'assets/lottieWin.json',
            repeat: true, // Repeat the animation
            reverse: false, // Do not play in reverse
            animate: true, // Play the animation
          ),
),
SizedBox(height: Get.height * 0.08,),
Text("You finished the quiz successfully!",style: TextStyle(fontWeight: FontWeight.bold,fontSize: Get.width * 0.05,color: Colors.green),)
    ],
  ),
   ); 
}
else{
  return    
  Container(
        margin: EdgeInsets.symmetric(
        horizontal: Get.width * 0.05,
        vertical: Get.height * 0.15,
      ),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(        color: Colors.black.withOpacity(0.2), // Shadow color
        spreadRadius: 2, // Spread radius
        blurRadius: 10, // Blur radius
        offset: Offset(0, 4),)
    ]// Add borderRadius
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(20), // Ensure clipping for child content
    child: SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 255, 255, 255),
            height: Get.height*0.31,
            width: Get.width,
            child: Column(
              children: [
                Container(
                  height: Get.height*0.24,
                  width: Get.width,
                  margin: EdgeInsets.only(top: Get.height*0.016, left: Get.width*0.033, right: Get.width*0.033),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Color.fromARGB(255, 152, 57, 241),
                        Color.fromARGB(255, 173, 114, 228),
                        Color.fromARGB(255, 189, 148, 227),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Obx((){return Text(viewModel.spokenText.value, 
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Get.width*0.04,
                    ),) ; })),
                ),
                SizedBox(height: Get.height*0.02),
                Obx((){ return LinearPercentIndicator(
                  barRadius: Radius.circular(50),
                  width: Get.width - 50,
                  lineHeight: Get.height*0.012,
                  animation: false,
                  percent: viewModel.progress.value,
                  linearGradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 233, 182, 73),
                      Color.fromARGB(255, 223, 98, 9)
                    ],
                  ),
                  backgroundColor:
                      const Color.fromARGB(255, 255, 255, 255),
                );}),
              ],
            ),
          ),
          SizedBox(height: Get.height*0.055),
          viewModel.starting.value!=0?
          Obx((){return Text("${viewModel.starting.value}",style:TextStyle(fontSize: Get.width * 0.13,fontFamily: 'RobotMono',fontWeight: FontWeight.bold)) ; }):
          Container(
          height: Get.height*0.1, // Set your desired height
          width: Get.width*0.3,  // Set your desired width
          child: Lottie.asset(
            'assets/lottieCat.json',
            repeat: true, // Repeat the animation
            reverse: false, // Do not play in reverse
            animate: true, // Play the animation
          ),
        ),
          SizedBox(height: Get.height*0.05),
          Padding(
            padding: EdgeInsets.all(Get.width * 0.025),
            child: Obx((){
            if (viewModel.vocabularyList.isEmpty || viewModel.subQuestionCurrentValue.value.isEmpty ) {
            return Center(
            child: CircularProgressIndicator(), // Show a loader until data is fetched
            );
           }
           
           else{
            print(viewModel.subQuestionCurrentValue.value.length);
               return PinCodeTextField(
                focusNode: _focusNode,
                autoDisposeControllers: false,
              controller: _pinController,
              key: ValueKey(viewModel.subQuestionCurrentValue.value),
              autoDismissKeyboard: true,
              appContext: context,
              length: viewModel.subQuestionCurrentValue.value.length ,
           // Default fallback length,
              cursorColor: Color.fromARGB(255, 152, 57, 241),
              obscureText: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                inactiveColor: Colors.purple,
                activeColor: Colors.purple,
                selectedColor: Colors.red,
                shape: PinCodeFieldShape.underline,
                fieldHeight: Get.height*0.032,
                fieldWidth: inputWidth(viewModel.subQuestionCurrentValue.value.length),
                activeFillColor: Color.fromARGB(255, 152, 57, 241),
              ),
              animationDuration: Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              enableActiveFill: false,
              enabled: viewModel.isGameStarted.value && !viewModel.isNextQuestion.value,
              onCompleted: (v) {
                print("Completed");
                _pinController.clear();
                 _focusNode.unfocus();
                viewModel.checkAnswer(v);
              },
              onChanged: (value) {
                print(value);
                setState(() {});
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                return true;
              },
            );}
})
          ),
          SizedBox(height: Get.height * 0.035),
          Obx((){
               return      
                  viewModel.isNextQuestion.value? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: Get.width * 0.025,
                      vertical: Get.height * 0.01,
                    ),
                    backgroundColor: const Color.fromARGB(255, 241, 153, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: Icon(
                    Icons.navigate_next,
                    color: Colors.white,
                    size: Get.width * 0.06,
                  ),
                  label: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: Get.width * 0.05,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    viewModel.startProgressTimer();
                    viewModel.isNextQuestion.value=false;
                    viewModel.spokenText.value= "Listen carefully and write the right word " ; 
                     viewModel.speakWord(viewModel.spokenText.value); 
                    Future.delayed(Duration(seconds: 3), () {
                       viewModel.speakWord(viewModel.currentWord.word);
                    }); 
                    },
                ):Text("");})

        ],
      ),
    ),
  ),
); 
}

       })
      ),
    );
  }

  double inputWidth(int length){
      if(length<=4){
        return Get.width * 0.17 ; 
      }
      else if (length<=8){
        return Get.width * 0.10 ; 
      }
      else if (length<=12){
        return Get.width * 0.05 ; 
      }
      else if (length<=16){
        return Get.width * 0.04 ; 
      }
      else if (length<=20){
        return Get.width * 0.035 ; 
      }
      else if (length<=24){
        return Get.width * 0.030 ; 
      }
      else return Get.width * 0.025 ; 
  }

  Widget displayRemaningTime(String input ){
    if(input == "0:00:00"){
      return IconButton(
    onPressed:  isButtonEnabled
          ? () {
              // Disable the button immediately
              setState(() {
                isButtonEnabled = false;
              });

              // Delay and execute the game start logic
              Future.delayed(Duration(seconds: 1), () {
                if (viewModel.lockRemainingTime.value == "0:00:00") {
                  gameStateController.isGameInProgress.value = true;
                  viewModel.isGameLocked.value = false;
                  viewModel.endGame.value = false;
                  viewModel.startGame();
                }
              });
            }
          : null, // Disable the button
      icon: Icon(Icons.start));
    }
    else{
      return
      Text("Remaning time: ${viewModel.lockRemainingTime.value}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: Get.width * 0.045,color: Colors.red));
    }
  }
}