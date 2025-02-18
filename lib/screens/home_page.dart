import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'profile_page.dart';
import 'food_page.dart';
import 'tips_page.dart';
import 'history_page.dart';
import 'about_us.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'recipe_screen.dart';
import 'package:flutterproject/widgets/calorie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'bmi_screen.dart';
import 'chatgpt_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> selectedFoods = []; // Today's Foods
  List<Map<String, dynamic>> favoriteFoods = []; // Saved Foods for History
  Set<String> favoriteFoodNames = {}; // To track favorite foods

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 @override
void initState() {
  super.initState();
  _loadSelectedFoods();
  _loadCalorieGoal();
  _loadFavorites();


  // to reset the list everyday
  Timer.periodic(Duration(minutes: 1), (timer) {
    DateTime now = DateTime.now();
    if (now.hour == 0 && now.minute == 0) {  
      print("Reset triggered at midnight!");
      _loadSelectedFoods();
    }
  });
}

Future<void> _loadFavorites() async {
  final String? userId = _auth.currentUser?.uid;
  if (userId == null) return;

  try {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey("favourites")) {
        Map<String, dynamic> favFoods = data["favourites"];

        setState(() {
          favoriteFoodNames = favFoods.keys.toSet(); 
        });
      }
    }
  } catch (e) {
    print("❌ Error loading favorites: $e");
  }
}
Timestamp selectedTimestamp = Timestamp.now(); 

Future<void> _selectDate(BuildContext context) async {
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedTimestamp.toDate(),
    firstDate: DateTime(2024, 1, 1), 
    lastDate: DateTime.now(), 
  );

  if (picked != null) {
    setState(() {
      selectedTimestamp = Timestamp.fromDate(picked); 
    });

    _loadSelectedFoods(selectedTimestamp: selectedTimestamp);
  }
}


Future<void> _loadSelectedFoods({Timestamp? selectedTimestamp}) async {
  final String? userId = _auth.currentUser?.uid;
  if (userId == null) return;

  try {
    Timestamp dateToLoad = selectedTimestamp ?? Timestamp.now(); 

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey("selectedFoods")) {
        List<dynamic> allFoods = data["selectedFoods"];

        // ✅ Convert Timestamp to Date (ignoring time)
        DateTime selectedDate = dateToLoad.toDate();
        String selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

        // ✅ Filter foods by date only (ignoring time)
        List<Map<String, dynamic>> filteredFoods = allFoods.where((food) {
          Timestamp foodTimestamp = food["date"];
          DateTime foodDate = foodTimestamp.toDate();
          return DateFormat('yyyy-MM-dd').format(foodDate) == selectedDateStr;
        }).map((food) => Map<String, dynamic>.from(food)).toList();

        setState(() {
          selectedFoods = filteredFoods;
        });

        print("✅ Loaded foods for $selectedDateStr: ${filteredFoods.length} items");
      } else {
        setState(() {
          selectedFoods = [];
        });
        print("🟡 No food records found for $selectedTimestamp.");
      }
    }
  } catch (e) {
    print("❌ Error loading selected foods: $e");
  }
}




Future<void> _saveSelectedFoodsToFirestore() async {
  final String? userId = _auth.currentUser?.uid;
  if (userId == null) return;

  try {
    Timestamp todayTimestamp = Timestamp.now(); 

    List<Map<String, dynamic>> foodsWithDate = selectedFoods.map((food) {
   
      return {
        ...food,
        "date": food.containsKey("date") ? food["date"] : todayTimestamp, 
      };
    }).toList();

    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    await userDoc.set({"selectedFoods": foodsWithDate}, SetOptions(merge: true));

    print("✅ Selected foods saved with timestamp: $todayTimestamp");

  } catch (e) {
    print("❌ Error saving selected foods: $e");
  }
}




  void _addFoodItem(Map<String, dynamic> newFood) {
    setState(() {
      int existingIndex = selectedFoods.indexWhere((food) => food["name"] == newFood["name"]);
      if (existingIndex != -1) {
        selectedFoods[existingIndex]["quantity"] += newFood["quantity"];
      } else {
        selectedFoods.add(newFood);
      }
    });

    Fluttertoast.showToast(msg: "${newFood["name"]} added to Today's List!", gravity: ToastGravity.TOP);
    _saveSelectedFoodsToFirestore(); 
  }

  void _addFoodItems(List<Map<String, dynamic>> foods) {
    for (var food in foods) {
      _addFoodItem(food);
    }
  }

  // Delete food from Today list
  void _deleteFoodItem(int index) {
    setState(() {
      selectedFoods.removeAt(index);
    });
    _saveSelectedFoodsToFirestore();
  }

  // Add to Firestore Favorites 
  Future<void> _addToFavorites(Map<String, dynamic> food) async {
  final String? userId = _auth.currentUser?.uid;
  if (userId == null) {
    Fluttertoast.showToast(msg: "User not logged in!", gravity: ToastGravity.TOP);
    return;
  }

  String foodName = food["name"];

  if (favoriteFoodNames.contains(foodName)) {
    Fluttertoast.showToast(msg: "$foodName is already in favorites!", gravity: ToastGravity.TOP);
    return;
  }

  try {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDoc);

      Map<String, dynamic> existingFavorites = {};
      if (snapshot.exists && snapshot.data() != null) {
        existingFavorites = (snapshot.data() as Map<String, dynamic>)["favourites"] ?? {};
      }

      int newQuantity = (existingFavorites[foodName]?["quantity"] ?? 0) + food["quantity"];

      Map<String, dynamic> updatedFood = {
        "name": food["name"],
        "imageUrl": food["imageUrl"],
        "calories": food["calories"] ?? 0,
        "quantity": newQuantity,
      };

      transaction.set(userDoc, {
        "favourites": {foodName: updatedFood}
      }, SetOptions(merge: true));
    });

    setState(() {
      favoriteFoodNames.add(foodName); 
    });

    Fluttertoast.showToast(msg: "$foodName added to favorites!", gravity: ToastGravity.TOP);
  } catch (e) {
    print("❌ Error adding favorite: $e");
    Fluttertoast.showToast(msg: "Failed to add favorite", gravity: ToastGravity.TOP);
  }
}


void _loadCalorieGoal() async {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  try {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        calorieGoal = (userDoc["calorieGoal"] ?? 2000).toDouble(); 
      });
    }
  } catch (e) {
    print("❌ Error loading calorie goal: $e");
  }
}

double calorieGoal = 2000.0; 

void _setCalorieGoal() {
  TextEditingController goalController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Set Calorie Goal"),
        content: TextField(
          controller: goalController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(hintText: "Enter calorie goal (e.g., 1500.5)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              double newGoal = double.tryParse(goalController.text) ?? 2000.0;
              setState(() {
                calorieGoal = newGoal;
              });

              // to save new calorie goal to Firestore
              final String? userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({"calorieGoal": newGoal});
              }

              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      );
    },
  );
}

void _adjustCalorieGoal(int change) async {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  setState(() {
    //to prevent unreliastic or impossible value
    calorieGoal = (calorieGoal + change).clamp(500.0, 5000.0); 
  });

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({"calorieGoal": calorieGoal});
  } catch (e) {
    print("❌ Error updating calorie goal: $e");
  }
}





  @override
  Widget build(BuildContext context) {
  String todayDate = DateFormat('MMMM d, y').format(DateTime.now().toLocal());


    double totalCalories = selectedFoods.fold(
      0,
      (sum, food) => sum + (food["calories"] ?? 0) * (food["quantity"] ?? 0),
    );

    return Scaffold(
     appBar: AppBar(
  backgroundColor: Color(0xFFDD6937),
  title: const Text(
    'Food Tracker',
    style: TextStyle(color: Colors.white), 
  ),
  iconTheme: const IconThemeData(color: Colors.white), 
),

     drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: <Widget>[
      DrawerHeader(
        decoration: BoxDecoration(
          color: Color(0xFFF9E0AE), 
        ),
        child: Center(
          child: Image.asset(
            'images/logo.png',
            width: 300,
            height: 250,
            fit: BoxFit.contain,
          ),
        ),
      ),
      
      // Profile
      Container(
        
       color: Color(0xFFE6DBC0),
        child: ListTile(
          leading: Icon(Icons.account_circle, color: Color(0xFFC24914)),
          title: Text('Profile', style: TextStyle(color: Color(0xFFC24914), fontWeight: FontWeight.bold)),
          onTap: () {
            String userId = FirebaseAuth.instance.currentUser!.uid;
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)));
          },
        ),
      ),
Container(
  color: Color(0xFFF7EBCD), 
  child: ListTile(
    leading: Icon(Icons.chat, color: Color(0xFFC24914)), 
    title: Text(
      'Food Analysis',
      style: TextStyle(color: Color(0xFFC24914), fontWeight: FontWeight.bold),
    ),
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ChatGPTScreen()), 
      );
    },
  ),
),


      // Food Tracker
      Container(
        color: Color(0xFFE6DBC0),
        child: ListTile(
          leading: Icon(Icons.fastfood, color: Color(0xFFC24914)),
          title: Text('Food Tracker', style: TextStyle(color: Color(0xFFC24914), fontWeight: FontWeight.bold)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => FoodPage(onAddFood: _addFoodItems)));
          },
        ),
      ),

      // Tips & Fun Facts
      Container(
        color: Color(0xFFF7EBCD),
        child: ListTile(
          leading: Icon(Icons.accessibility, color: Color(0xFFC24914)),
          title: Text('Tips & Fun Facts', style: TextStyle(color: Color(0xFFC24914), fontWeight: FontWeight.bold)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => TipsPage()));
          },
        ),
      ),

      //  Recipes
      Container(
        color: Color(0xFFE6DBC0),
        child: ListTile(
          leading: Icon(Icons.book, color: Color(0xFFC24914)),
          title: Text('Recipes', style: TextStyle(color: Color(0xFFC24914), fontWeight: FontWeight.bold)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => RecipeScreen()));
          },
        ),
      ),

      //  Favorites
      Container(
        color: Color(0xFFF7EBCD),
        child: ListTile(
          leading: Icon(Icons.favorite, color: Color(0xFFC24914)),
          title: Text('Favorites', style: TextStyle(color: Color(0xFFC24914), fontWeight: FontWeight.bold)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => HistoryPage(onAddToHome: _addFoodItem)));
          },
        ),
      ),

      // BMI Calculator
      Container(
        color: Color(0xFFE6DBC0),
        child: ListTile(
          leading: Icon(Icons.calculate, color: Color(0xFFC24914)),
          title: Text('BMI Calculator', style: TextStyle(color: Color(0xFFC24914), fontWeight: FontWeight.bold)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => BMIScreen()));
          },
        ),
      ),

      // About Us
      Container(
        color: Color(0xFFF7EBCD),
        child: ListTile(
          leading: Icon(Icons.info, color: Color(0xFFC24914)),
          title: Text('About Us', style: TextStyle(color: Color(0xFFC24914), fontWeight: FontWeight.bold)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AboutUsPage()));
          },
        ),
      ),

      //  Log Out
      Container(
        color: Color(0xFFE6DBC0),
        child: ListTile(
          leading: Icon(Icons.logout, color: Color(0xFFC24914)),
          title: Text('Log Out', style: TextStyle(color: Color(0xFFC24914), fontWeight: FontWeight.bold)),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
      ),
    ],
  ),
),

     body: Container(
    color: Color(0xFFF7EBCD), 
    
  child: Column(
    children: [
       Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Image.asset(
          'images/tracker.png', 
          height: 150,  
               
          fit: BoxFit.contain,  
        ),
      ),
      const SizedBox(height: 20),
   Text(
      "Selected Date: ${DateFormat('MMMM d, y').format(selectedTimestamp.toDate())}",
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    ),
    IconButton(
      icon: Icon(Icons.calendar_today, color: Color(0xFFDD6937)),
      onPressed: () => _selectDate(context), // Opens the date picker
    ),
SizedBox(height: 10), 

      Expanded(
        child: selectedFoods.isEmpty
            ? const Center(child: Text("No food items added yet."))
            : ListView.builder(
                itemCount: selectedFoods.length,
                itemBuilder: (context, index) {
                  final food = selectedFoods[index];

                  return Card(
                      color: Color(0xFFF9E0AE), 
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Image.network(
                        food["imageUrl"],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        "${food["quantity"]}x ${food["name"]}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Calories: ${(food["calories"] ?? 0) * (food["quantity"] ?? 0)} kcal",
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: favoriteFoodNames.contains(food["name"])
                                  ? Colors.grey
                                  : Colors.orange,
                            ),
                            onPressed: favoriteFoodNames.contains(food["name"])
                                ? null
                                : () {
                                    _addToFavorites(food);
                                  },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFoodItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Total Calories: ${totalCalories.toStringAsFixed(2)} kcal",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: CalorieChart(
                  calorieGoal: calorieGoal.toInt(),
                  caloriesConsumed: totalCalories.toInt(),
                  onGoalChange: _adjustCalorieGoal,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

      
   floatingActionButton: FloatingActionButton(
  backgroundColor: Color(0xFFDD6937), 
  child: const Icon(Icons.add, color: Colors.white), 
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodPage(
          onAddFood: _addFoodItems,
        ),
      ),
    );
  },
),

    );
  }
}