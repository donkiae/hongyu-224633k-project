import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/spoonacular_service.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final int recipeId;
  final String recipeTitle;
  final String recipeImage;

  RecipeDetailsScreen({required this.recipeId, required this.recipeTitle, required this.recipeImage});

  @override
  _RecipeDetailsScreenState createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final SpoonacularService _recipeService = SpoonacularService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _recipeDetails;
  bool _isLoading = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails();
    _checkIfRecipeSaved();
  }

  Future<void> _fetchRecipeDetails() async {
    try {
      final details = await _recipeService.fetchRecipeDetails(widget.recipeId);
      setState(() {
        _recipeDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching recipe details: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIfRecipeSaved() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final recipeDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('savedRecipes')
        .doc(widget.recipeId.toString())
        .get();

    setState(() {
      _isSaved = recipeDoc.exists;
    });
  }

  Future<void> _toggleSaveRecipe() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    DocumentReference recipeRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('savedRecipes')
        .doc(widget.recipeId.toString());

    if (_isSaved) {
      // If already saved, removed
      await recipeRef.delete();
      setState(() => _isSaved = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Recipe removed from saved.")));
    } else {
      //Save the recipe
      await recipeRef.set({
        "recipeId": widget.recipeId,
        "title": widget.recipeTitle,
        "image": widget.recipeImage,
        "timestamp": FieldValue.serverTimestamp(), 
      });

      setState(() => _isSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Recipe saved!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDD6937), 
        title: Text(
          widget.recipeTitle,
          style: TextStyle(color: Colors.white), 
        ),
        iconTheme: IconThemeData(color: Colors.white), 
      ),
      body: Container(
        color: Color(0xFFF7EBCD), 
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _recipeDetails == null
                ? Center(
                    child: Text(
                      "No recipe details available.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDD6937), 
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.recipeImage,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Ingredients Section
                        Text(
                          "Ingredients",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDD6937), 
                          ),
                        ),
                        ...(_recipeDetails!["extendedIngredients"] as List)
                            .map((ingredient) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Text(
                                    "• ${ingredient["original"]}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )),

                        SizedBox(height: 10),

             
                        Text(
                          "Instructions",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDD6937), 
                          ),
                        ),
                        Text(
                          _recipeDetails!["instructions"] ?? "No instructions available.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}