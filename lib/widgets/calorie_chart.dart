import 'package:flutter/material.dart';

class CalorieChart extends StatelessWidget {
  final int calorieGoal;
  final int caloriesConsumed;
  final Function(int) onGoalChange; 

  const CalorieChart({
    super.key,
    required this.calorieGoal,
    required this.caloriesConsumed,
    required this.onGoalChange, 
  });

  @override
  Widget build(BuildContext context) {
    double progress = (caloriesConsumed / calorieGoal).clamp(0.0, 1.0); 

    return Column(
      children: [
        Text(
          "Calorie Progress",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        Container(
          width: double.infinity,
          height: 30, 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                //to dynamically load progress
                widthFactor: progress, 
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: progress >= 1 ? Colors.red : Colors.green, 
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
       // for calorie goal buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => onGoalChange(-100), 
            ),
            Text(
              "Goal: ${calorieGoal.toInt()} kcal", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => onGoalChange(100), 
            ),
          ],
        ),
        SizedBox(height: 5),
        
        Text(
          "Consumed: $caloriesConsumed kcal | Remaining: ${calorieGoal - caloriesConsumed} kcal",
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
