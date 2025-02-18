import 'package:flutter/material.dart';
import '../services/food_api_service.dart';
import 'package:flutterproject/Food.dart';
import 'home_page.dart';  

class FoodPage extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onAddFood;

  const FoodPage({Key? key, required this.onAddFood}) : super(key: key);

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final SpoonacularApiService _apiService = SpoonacularApiService();
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  List<FoodItem> _foodList = [];
  Map<int, double?> _calories = {}; 
  Map<int, int> _quantities = {}; 

  void _searchFood() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _loading = true);

    try {
      final FoodResponse result = await _apiService.searchFood(query);

      setState(() {
        _foodList = result.results;
        _quantities.clear();
      });

      for (var food in result.results) {
        double? calories = await _apiService.getFoodCalories(food.id);
        setState(() {
          _calories[food.id] = calories;
          _quantities[food.id] = 0;
        });
      }
    } catch (e) {
      print("Error fetching food: $e");
      setState(() {
        _foodList = [];
        _calories = {};
        _quantities = {};
      });
    }

    setState(() => _loading = false);
  }

  void _incrementQuantity(int foodId) {
    setState(() {
      _quantities[foodId] = (_quantities[foodId] ?? 0) + 1;
    });
  }

  void _decrementQuantity(int foodId) {
    setState(() {
      if ((_quantities[foodId] ?? 0) > 0) {
        _quantities[foodId] = (_quantities[foodId] ?? 0) - 1;
      }
    });
  }

  void _addToHomePage(FoodItem food) {
    if (_quantities[food.id] != null && _quantities[food.id]! > 0) {
      widget.onAddFood([
        {
          "name": food.name,
          "imageUrl": food.imageUrl,
          "calories": _calories[food.id],
          "quantity": _quantities[food.id]
        }
      ]);
      setState(() {
        _quantities[food.id] = 0; 
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xFFDD6937), 
      title: const Text(
        'Food Nutrition',
        style: TextStyle(color: Colors.white), 
      ),
      iconTheme: const IconThemeData(color: Colors.white), 
    ),
    body: Container(
      color: Color(0xFFF7EBCD), 
      child: Column(
        children: [
         Padding(
  padding: const EdgeInsets.all(10.0),
  child: Row(
    children: [
      Expanded(
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Enter Food Name',
            labelStyle: TextStyle(color: Color(0xFFDD6937)), 
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFDD6937), width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFDD6937), width: 2.5), 
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: _searchFood,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFDD6937), 
          foregroundColor: Colors.white, 
        ),
        child: const Text("Search"),
      ),
    ],
  ),
),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _foodList.isEmpty
                    ? const Center(child: Text(
    "No results found",
    style: TextStyle(
      fontSize: 16,
      color: Color(0xFFDD6937), 
    ),))
                    
                    : ListView.builder(
                        itemCount: _foodList.length,
                        itemBuilder: (context, index) {
                          final food = _foodList[index];
                          return Card(
                            color: Color(0xFFF9E0AE), 
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: Image.network(food.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                              title: Text(food.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _calories.containsKey(food.id)
                                        ? "Calories: ${_calories[food.id]?.toStringAsFixed(2)} kcal"
                                        : "Loading calories...",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () => _decrementQuantity(food.id),
                                      ),
                                      Text(_quantities[food.id]?.toString() ?? "0"),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () => _incrementQuantity(food.id),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.check_circle, color: Colors.green),
                                        onPressed: () => _addToHomePage(food),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    ),
  );
}
}