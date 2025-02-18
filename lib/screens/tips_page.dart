import 'package:flutter/material.dart';
import 'package:flutterproject/services/tips_service.dart';

class TipsPage extends StatefulWidget {
  @override
  _TipsPageState createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  final TipsService _tipsService = TipsService();

  String foodTrivia = "Loading trivia...";
  String foodJoke = "Loading joke...";
  String healthyTip = "Loading tip...";

  @override
  void initState() {
    super.initState();
    fetchFoodData();
  }


  void fetchFoodData() async {
    String trivia = await _tipsService.getRandomFoodTrivia();
    String joke = await _tipsService.getRandomFoodJoke();
    String tip = await _tipsService.getHealthyLivingTip(); 

    setState(() {
      foodTrivia = trivia;
      foodJoke = joke;
      healthyTip = tip;
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDD6937), 
        title: const Text(
          "Healthy Tips & Fun Facts",
          style: TextStyle(color: Colors.white), 
        ),
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
     body: Container(
  color: Color(0xFFF7EBCD), 
  child: Column(
    children: [
      Expanded( 
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("🍏 Healthy Living Tip:", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFDD6937))
              ),
              SizedBox(height: 5),
              Text(healthyTip, style: TextStyle(fontSize: 16)),
              Divider(),

              Text("🥗 Random Food Trivia:", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFDD6937))
              ),
              SizedBox(height: 5),
              Text(foodTrivia, style: TextStyle(fontSize: 16)),
              Divider(),

              Text("😂 Random Food Joke:", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFDD6937))
              ),
              SizedBox(height: 5),
              Text(foodJoke, style: TextStyle(fontSize: 16)),
              Divider(),
            ],
          ),
        ),
      ),
      

      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: fetchFoodData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFDD6937), 
            foregroundColor: Colors.white,
          ),
          child: Text("🔄 Refresh For New Facts"),
        ),
      ),
    ],
  ),
),

    );
  }
}