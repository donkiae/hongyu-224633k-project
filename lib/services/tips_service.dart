import 'dart:convert';
import 'package:http/http.dart' as http;

class TipsService {
  final String apiKey = "aed269c9c5d243ae94c497ae1140a1b1"; 


  Future<String> getRandomFoodTrivia() async {
    final url = Uri.parse("https://api.spoonacular.com/food/trivia/random?apiKey=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['text'];
    } else {
      return "Failed to load trivia.";
    }
  }


  Future<String> getRandomFoodJoke() async {
    final url = Uri.parse("https://api.spoonacular.com/food/jokes/random?apiKey=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['text'];
    } else {
      return "Failed to load joke.";
    }
  }

Future<String> getHealthyLivingTip() async {
  final String apiKey = "aed269c9c5d243ae94c497ae1140a1b1"; 
  final url = Uri.parse("https://api.spoonacular.com/food/trivia/random?apiKey=$apiKey");

  try {
    final response = await http.get(url);
    print("🔍 Response Status: ${response.statusCode}");
    print("🔍 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['text']; 
    } else {
      return "API Error: ${response.statusCode} - ${response.body}";
    }
  } catch (e) {
    return "Error: $e";
  }
}
}
