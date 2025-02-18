import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  late GoogleMapController mapController;
  final LatLng _mbsLocation = const LatLng(1.2834, 103.8607);

  final TextEditingController _feedbackController = TextEditingController();
  // default 5 star yay
  double _rating = 5.0; 

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _submitFeedback() async {
    String feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your feedback")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to be logged in to submit feedback")),
      );
      return;
    }

    DocumentReference userDoc = FirebaseFirestore.instance.collection("users").doc(user.uid);

    
    DocumentSnapshot docSnapshot = await userDoc.get();
    List<dynamic> feedbacks = docSnapshot.exists && docSnapshot.data() != null
        ? (docSnapshot["feedbacks"] as List<dynamic>?) ?? []
        : [];


    feedbacks.add({
      "feedback": feedback,
      "rating": _rating,
    });


    await userDoc.update({
      "feedbacks": feedbacks,
    });

    _feedbackController.clear();
    setState(() {
      _rating = 5.0;
    });

// to show user feedback sent
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback submitted successfully!")),
    );
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDD6937), 
        title: const Text(
          "About Us",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF7EBCD), 
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Image.asset(
              'images/about.png',  
              height: 200,          
              fit: BoxFit.contain,
            )
            ),
             const Text(
  "Background",
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFFDD6937), 
  ),
),
              const SizedBox(height: 10),
            const Text(
  "Food Tracker is your go-to app for managing daily nutrition effortlessly. "
  "Designed for those who want to monitor their food intake, discover new meal ideas, "
  "and maintain a balanced diet, our app provides intuitive features to simplify calorie tracking. "
  "With real-time insights and personalized meal logging, Food Tracker helps you stay on top of your health goals.",
  style: TextStyle(fontSize: 16),
),
              const SizedBox(height: 20),
              const Text(
                "Features:",
                  
                
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,    color: Color(0xFFDD6937),),
              ),
              const SizedBox(height: 5),
           const Text("✅ Log and track your daily calorie intake effortlessly"),
const Text("✅ Search for food items and get detailed nutrition information"),
const Text("✅ Add foods to your personal favorites for quick access"),
const Text("✅ Save and revisit your meal history to monitor your progress"),
const Text("✅ Set and adjust daily calorie goals to fit your needs"),
const Text("✅ View visual calorie charts to track your progress"),
const Text("✅ Explore personalized food suggestions based on your diet"),
const Text("✅ Calculate your BMI and assess your health status"),
const Text("✅ Get fun food facts and health tips for better choices"),
const Text("✅ Save and manage your favorite recipes with ease"),
const Text("✅ Submit feedback and rate the app to help us improve"),
const Text("✅ Seamlessly sync and store data using Firebase"),
              const SizedBox(height: 20),
              const Text(
                "Find Us Here",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,    color: Color(0xFFDD6937),),
              ),
              const SizedBox(height: 5),

              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _mbsLocation,
                      zoom: 15.0,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("mbs"),
                        position: _mbsLocation,
                        infoWindow: const InfoWindow(title: "Marina Bay Sands"),
                      ),
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Contact Us",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,    color: Color(0xFFDD6937),),
              ),
              const SizedBox(height: 5),
              const Text(
                "📧 Email: foodtracker@gmail.com",
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                "🌍 Website: www.foodtracker.com",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // ✅ Feedback Section
              const Text(
                "Your Feedback",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,    color: Color(0xFFDD6937),),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write your feedback here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFE6DBC0), 
                  hintStyle: const TextStyle(color: Color.fromARGB(255, 186, 163, 127)),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),

              //  Star Rating
              const Text(
                "Rate Our App",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,    color: Color(0xFFDD6937),),
              ),
              const SizedBox(height: 5),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 20),

        
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDD6937),
                  ),
                  onPressed: _submitFeedback,
                  child: const Text(
                    "Submit Feedback",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}