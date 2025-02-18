import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BMIScreen extends StatefulWidget {
  @override
  _BMIScreenState createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  double? bmi;
  String category = "Enter your details";

  @override
  void initState() {
    super.initState();
    _loadSavedValues(); 
  }

  // Save last entered values
  Future<void> _loadSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _weightController.text = prefs.getString("weight") ?? "";
      _heightController.text = prefs.getString("height") ?? "";
    });
  }

  Future<void> _saveValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("weight", _weightController.text);
    await prefs.setString("height", _heightController.text);
  }

  // Calculate BMI
  void _calculateBMI() {
    double? weight = double.tryParse(_weightController.text);
    double? height = double.tryParse(_heightController.text);

    if (weight == null || height == null || height <= 0) {
      setState(() {
        bmi = null;
        category = "Please enter valid values";
      });
      return;
    }

    // Convert cm to meters
    double heightInMeters = height / 100; 
    double calculatedBMI = weight / (heightInMeters * heightInMeters);

    setState(() {
      bmi = calculatedBMI;
      category = _getBMICategory(calculatedBMI);
    });

    _saveValues(); 
  }

  // Get BMI category
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return "Underweight 🟡";
    } else if (bmi < 24.9) {
      return "Normal weight 🟢";
    } else if (bmi < 29.9) {
      return "Overweight 🟠";
    } else {
      return "Obese 🔴";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color(0xFFDD6937), 
        title: const Text(
          "BMI Calculator",
          style: TextStyle(color: Colors.white), 
        ),
        iconTheme: IconThemeData(color: Colors.white), 
      ),
      body: Container(
        color: Color(0xFFF7EBCD), 
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'images/calc.png',
                height: 150, 
              ),
              Text(
                "Calculate your BMI",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Weight (kg)",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF9E0AE), 
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _heightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Height (cm)",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF9E0AE), 
                ),
              ),
              const SizedBox(height: 20),

            
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDD6937), 
                ),
                onPressed: _calculateBMI,
                child: const Text("Calculate BMI", style: TextStyle(color: Colors.white)), 
              ),
              const SizedBox(height: 20),

              // bmi result
              if (bmi != null)
                Column(
                  children: [
                    Text(
                      "Your BMI: ${bmi!.toStringAsFixed(1)}",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category,
                      style: TextStyle(fontSize: 20, color: Color(0xFFC24914)), 
                    ),
                  ],
                ),
              
              const SizedBox(height: 20),

              // BMI Ranges Table
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFF9E0AE), 
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      "BMI Categories",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFDD6937)),
                    ),
                    const SizedBox(height: 10),
                    Table(
                      border: TableBorder.all(color: Colors.black),
                      columnWidths: {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                      },
                      children: [
                        _buildTableRow("Category", "BMI Range", isHeader: true),
                        _buildTableRow("Underweight", "< 18.5"),
                        _buildTableRow("Normal weight", "18.5 - 24.9"),
                        _buildTableRow("Overweight", "25 - 29.9"),
                        _buildTableRow("Obese", "≥ 30"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Color(0xFFDD6937) : Colors.transparent, 
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Colors.white : Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
