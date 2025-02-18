import 'dart:convert';
import 'package:http/http.dart' as http;

class SpoonacularService {
  static const String apiKey = "aed269c9c5d243ae94c497ae1140a1b1";
  static const String baseUrl = "https://api.spoonacular.com/recipes";

  //Fetches recipes list
  Future<List<Map<String, dynamic>>> fetchRecipes({String query = "healthy"}) async {
    final url = Uri.parse("$baseUrl/complexSearch?query=$query&number=10&apiKey=$apiKey");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data["results"]);
      } else {
        throw Exception("Failed to load recipes. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to load recipes: $e");
    }
  }

  // Fetchs the (ingredients & instructions)
  Future<Map<String, dynamic>> fetchRecipeDetails(int recipeId) async {
    final url = Uri.parse("$baseUrl/$recipeId/information?includeNutrition=false&apiKey=$apiKey");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load recipe details. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to load recipe details: $e");
    }
  }
}
