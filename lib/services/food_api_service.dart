import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterproject/Food.dart';

class SpoonacularApiService {
  final String _apiKey = "aed269c9c5d243ae94c497ae1140a1b1";
  final String _baseUrl = "https://api.spoonacular.com";

  // Search for food items (gets name & image)
  Future<FoodResponse> searchFood(String foodName) async {
    final url = '$_baseUrl/food/ingredients/search?query=$foodName&apiKey=$_apiKey';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return FoodResponse.fromJson(json.decode(response.body)); 
      } else {
        throw Exception('❌ Failed to load food data: ${response.body}');
      }
    } catch (e) {
      throw Exception('❌ Failed to fetch data: $e');
    }
  }


  Future<double?> getFoodCalories(int foodId) async {
    final url = '$_baseUrl/food/ingredients/$foodId/information?amount=1&apiKey=$_apiKey';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData["nutrition"]["nutrients"]
            .firstWhere((nutrient) => nutrient["name"] == "Calories")["amount"];
      } else {
        throw Exception('❌ Failed to load nutrition data: ${response.body}');
      }
    } catch (e) {
      print("⚠️ Error fetching calories: $e");
      return null;
    }
  }
}
