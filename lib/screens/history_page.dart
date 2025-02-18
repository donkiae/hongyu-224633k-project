import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HistoryPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddToHome; 

  const HistoryPage({super.key, required this.onAddToHome});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId = "";
  Map<int, int> selectedQuantities = {}; // f0r Tracking selected quantities

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid ?? "";
    if (userId.isEmpty) {
      print("❌ Error: User ID is missing!");
    }
  }

  //  Remove a food item from favorites
  Future<void> removeFromFavorites(String foodName) async {
    if (userId.isEmpty) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'favourites.$foodName': FieldValue.delete(),
      });

      Fluttertoast.showToast(msg: "$foodName removed from favorites!", gravity: ToastGravity.TOP);
    } catch (e) {
      print("❌ Error removing favorite: $e");
      Fluttertoast.showToast(msg: "Failed to remove favorite", gravity: ToastGravity.TOP);
    }
  }

 @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFDD6937),
          title: const Text(
            "Food History",
            style: TextStyle(color: Colors.white), 
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          color: Color(0xFFF7EBCD), 
          child: const Center(
            child: Text(
              "User not logged in.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDD6937), 
        title: const Text(
          "Favorites",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white), 
      ),
      body: Container(
        color: Color(0xFFF7EBCD), 
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(userId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            var userData = snapshot.data?.data() as Map<String, dynamic>?;

            if (userData == null || !userData.containsKey('favourites')) {
              return Center(
                child: Text(
                  "No favorite foods yet.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              );
            }

            Map<String, dynamic> favourites = Map<String, dynamic>.from(userData['favourites']);
            List<Map<String, dynamic>> favoriteFoods = favourites.values.map((item) => Map<String, dynamic>.from(item)).toList();

            return ListView.builder(
              itemCount: favoriteFoods.length,
              itemBuilder: (context, index) {
                final food = favoriteFoods[index];

           
                int quantity = selectedQuantities[index] ?? 1;

                return Card(
                  color: Color(0xFFF9E0AE), 
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: food["imageUrl"] != null && food["imageUrl"].isNotEmpty
                        ? Image.network(food["imageUrl"], width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.fastfood, color: Color(0xFFDD6937)), 

                    title: Text(
                      food["name"] ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC24914), 
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Calories per unit: ${food["calories"] ?? 0} kcal",
                          style: const TextStyle(fontSize: 16),
                        ),

                       
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 1) {
                                    selectedQuantities[index] = quantity - 1;
                                  }
                                });
                              },
                            ),
                            Text(
                              "$quantity",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  selectedQuantities[index] = quantity + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFDD6937), 
                          ),
                          onPressed: () {
                            Map<String, dynamic> foodToAdd = {
                              "name": food["name"],
                              "calories": food["calories"],
                              "quantity": quantity, 
                              "imageUrl": food["imageUrl"],
                            };
                            // to add back to today's list
                            widget.onAddToHome(foodToAdd);
                            Fluttertoast.showToast(
                                msg: "${food["name"]} added to Today's List!", gravity: ToastGravity.TOP);
                          },
                          child: const Text("Add", style: TextStyle(color: Colors.white)), 
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            removeFromFavorites(food["name"]); 
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}