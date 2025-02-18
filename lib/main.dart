import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'services/firebase_options.dart';
import 'screens/recipe_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Firestore App',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
      home: const LoginPage(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutterproject/services/openai_service.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final OpenAIService openAIService = OpenAIService();
//   String? foodAnalysis;
//   File? selectedImage;
//   bool isLoading = false;

//   Future<void> _analyzeFood() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile == null) return;

//     setState(() {
//       isLoading = true;
//       foodAnalysis = null;
//       selectedImage = File(pickedFile.path);
//     });

//   String? result = await openAIService.analyzeFood("What food is in this image?");


//     setState(() {
//       foodAnalysis = result;
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text("Food Recognition & Nutrition Info")),
//         body: SingleChildScrollView(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: _analyzeFood,
//                 child: Text("Upload & Analyze"),
//               ),
//               SizedBox(height: 20),

//               // 📸 Display the uploaded image
//               if (selectedImage != null)
//                 Column(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.file(
//                         selectedImage!,
//                         height: 250,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                   ],
//                 ),

//               // 📑 Display Analysis Result
//               Text(
//                 "Analysis Result:",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10),

//               isLoading
//                   ? CircularProgressIndicator()
//                   : foodAnalysis != null
//                       ? Container(
//                           padding: EdgeInsets.all(15),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.3),
//                                 blurRadius: 5,
//                                 spreadRadius: 1,
//                               ),
//                             ],
//                           ),
//                           child: Text(
//                             foodAnalysis!,
//                             style: TextStyle(fontSize: 16, height: 1.5),
//                           ),
//                         )
//                       : Text("No analysis yet. Upload an image."),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
