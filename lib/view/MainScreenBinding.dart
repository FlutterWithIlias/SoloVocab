import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_vocabulary/viewModel/TypesCountViewModel.dart';
import 'package:circular_charts/circular_charts.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final MainScreenViewModel viewModel = Get.find<MainScreenViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    viewModel.fetchCounts(); // Initial fetch
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Fetch data when returning to the app
      viewModel.fetchCounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Main Screen"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            // Top section with counts
            Expanded(
              flex: 1,
              child: Obx(() {
                final counts = viewModel.counts.value;

                if (counts == null) {
                  return Center(child: CircularProgressIndicator());
                }

                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: screenWidth * 0.04,
                  mainAxisSpacing: screenHeight * 0.02,
                  childAspectRatio: screenWidth / (screenHeight * 0.5),
                  children: [
                    _buildCountCard("Nouns", counts.nouns, Colors.green, screenWidth, screenHeight),
                    _buildCountCard("Verbs", counts.verbs, Colors.red, screenWidth, screenHeight),
                    _buildCountCard("Adjectives", counts.adjectives, Colors.blue, screenWidth, screenHeight),
                    _buildCountCard("Adverbs", counts.adverbs, Colors.yellow, screenWidth, screenHeight),
                  ],
                );
              }),
            ),
            // Circular chart
            Container(
              height: screenHeight*0.29,
              margin: EdgeInsets.only(bottom: screenHeight * 0.1),
              decoration: BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment:  CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(   "Objective: 1000 words", 
                          style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),),
                  
                  Obx(() {
                    final counts = viewModel.counts.value;
                  
                    if (counts == null) {
                      return Center(child: CircularProgressIndicator());
                    }
                  
                    final total = counts.total;
                  
                    if (total == 0) {
                      return Text(
                        "No Data Available",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      );
                    }
                  
                    return Expanded(
                      child: CircularChart(
                        chartHeight: screenHeight * 0.28,
                        chartWidth: screenWidth * 0.85,
                        animationTime: 800,
                        isShowingLegend: true,
                        isShowingCentreCircle: true,
                        centreCircleTitle: total > 0 ? "$total" : "No Data",
                        centreCircleBackgroundColor: Colors.white,
                        overAllPercentage: (total / 1000) * 100,
                        pieChartChildNames: ["Nouns", "Verbs", "Adjectives", "Adverbs"],
                        pieChartPercentages: [
                          double.parse(((counts.nouns / total) * 100).toStringAsFixed(2)),
                          double.parse(((counts.verbs / total) * 100).toStringAsFixed(2)),
                          double.parse(((counts.adjectives / total) * 100).toStringAsFixed(2)),
                          double.parse(((counts.adverbs / total) * 100).toStringAsFixed(2)),
                        ],
                        pieChartStartColors: [
                          Colors.green.withOpacity(0.8),
                          Colors.red.withOpacity(0.8),
                          Colors.blue.withOpacity(0.8),
                          Colors.yellow.withOpacity(0.8),
                        ],
                        pieChartEndColors: [
                          Colors.green,
                          Colors.red,
                          Colors.blue,
                          Colors.yellow,
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard(String title, int count, Color color, double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: screenWidth * 0.04,
            offset: Offset(0, screenHeight * 0.01),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: count),
              duration: Duration(seconds: 1),
              builder: (context, value, child) {
                return Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
