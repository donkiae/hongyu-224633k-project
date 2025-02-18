





import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe_details_screen.dart';
import '../services/spoonacular_service.dart';
import 'dart:async';

class RecipeScreen extends StatefulWidget {
  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final SpoonacularService _recipeService = SpoonacularService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _recipes = [];
  List<Map<String, dynamic>> savedRecipes = []; 
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce; 

  @override
  void dispose() {
    _debounce?.cancel(); 
    super.dispose();
  }

  // Debouncer method
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchRecipes(query: query);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchRecipes();
    _fetchSavedRecipes(); 
  }


Future<void> _fetchSavedRecipes() async {
  final String? userId = _auth.currentUser?.uid;
  if (userId == null) return;

  try {
    DocumentSnapshot userDoc =
        await _firestore.collection("users").doc(userId).get();

    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      if (data.containsKey("savedRecipes")) {
        setState(() {
          savedRecipes = List<Map<String, dynamic>>.from(data["savedRecipes"]);
        });
      }
    }

    fetchRecipes(); 

  } catch (e) {
    print("❌ Error fetching saved recipes: $e");
  }
}

Future<void> fetchRecipes({String query = "healthy"}) async {
  setState(() => _isLoading = true);
  
  try {
    List<Map<String, dynamic>> fetchedRecipes = await _recipeService.fetchRecipes(query: query);


    Set<int> savedIds = savedRecipes.map((recipe) => recipe["id"] as int).toSet();
    List<Map<String, dynamic>> mergedRecipes = [
      ...savedRecipes, //to show favourites recipe first
      ...fetchedRecipes.where((recipe) => !savedIds.contains(recipe["id"])), 
    ];

    setState(() {
      _recipes = mergedRecipes;
    });

  } catch (e) {
    print("Error fetching recipes: $e");
  }

  setState(() => _isLoading = false);
}


  // to put save recipe on top
  void _prioritizeSavedRecipes() {
    setState(() {
      _recipes.sort((a, b) {
        bool isAInSaved = savedRecipes.any((recipe) => recipe["id"] == a["id"]);
        bool isBInSaved = savedRecipes.any((recipe) => recipe["id"] == b["id"]);

        return (isBInSaved ? 1 : 0).compareTo(isAInSaved ? 1 : 0);
      });
    });
  }

  Future<void> _toggleSaveRecipe(Map<String, dynamic> recipe) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    bool isAlreadySaved =
        savedRecipes.any((saved) => saved["id"] == recipe["id"]);

    try {
      if (isAlreadySaved) {
        // 🔥 Remove recipe if already saved
        savedRecipes.removeWhere((saved) => saved["id"] == recipe["id"]);
      } else {
        // ✅ Save recipe if not already saved
        savedRecipes.add({
          "id": recipe["id"],
          "name": recipe["title"],
          "image": recipe["image"],
        });
      }

      await _firestore.collection("users").doc(userId).update({
        "savedRecipes": savedRecipes,
      });

 
      setState(() {
        _prioritizeSavedRecipes();
      });

    } catch (e) {
      print("❌ Error saving recipe: $e");
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xFFDD6937), 
      title: const Text(
        "Recipes",
        style: TextStyle(color: Colors.white), 
      ),
      iconTheme: const IconThemeData(color: Colors.white), 
    ),
    body: Container(
      color: Color(0xFFF7EBCD), 
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search recipes...",
                hintStyle: TextStyle(color: Color(0xFFDD6937)), 
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFDD6937), width: 2.0), 
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFDD6937), width: 2.5), 
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Color(0xFFDD6937)), 
                  onPressed: () {
                    fetchRecipes(query: _searchController.text);
                  },
                ),
              ),
              onChanged: _onSearchChanged, 
            ),
          ),

          // Recipe List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      bool isSaved = savedRecipes.any((r) => r["id"] == recipe["id"]);

                      return Card(
                        color: Color(0xFFF9E0AE), 
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: Image.network(
                            recipe["image"],
                            width: 80, 
                            height: 80, 
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            recipe["title"] ?? recipe["name"] ?? "No Title",
                            style: TextStyle( color: Color(0xFFDD6937)), 
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isSaved ? Icons.favorite : Icons.favorite_border,
                              color: isSaved ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => _toggleSaveRecipe(recipe),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailsScreen(
                                  recipeId: recipe["id"],
                                  recipeTitle: recipe["title"] ?? recipe["name"] ?? "No Title",
                                  recipeImage: recipe["image"] ?? "",
                                ),
                              ),
                            );
                          },
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