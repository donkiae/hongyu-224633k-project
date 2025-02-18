import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  bool signUp = true;
  bool isLoading = false;

   @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7EBCD),
      child: Scaffold(
        backgroundColor: Colors.transparent, 
        // appBar: AppBar(
        //   backgroundColor: const Color(0xFFDD6937), 
        //   title: const Text('Login', style: TextStyle(color: Colors.white)),
        //   iconTheme: const IconThemeData(color: Colors.white),
        // ),
        resizeToAvoidBottomInset: true, 
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Image.asset(
                      'images/logo.png',
                      width: 400,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),

                  if (signUp) 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: const TextStyle(color: Color(0xFFC24914)), // ✅ Match text color
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFC24914)), // ✅ Border color
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFC24914)), // ✅ Focus border color
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Color(0xFFC24914)), // ✅ Match text color
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFC24914)), // ✅ Border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFC24914)), // ✅ Focus border color
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Color(0xFFC24914)), 
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFC24914)), 
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFC24914)), 
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            setState(() => isLoading = true);
                            if (signUp) {
                              var newUser = await FirebaseAuthService().signUp(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                username: usernameController.text.trim(),
                                
                              );
                              if (newUser != null) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => const HomePage()),
                                );
                              }
                            } else {
                              var regUser = await FirebaseAuthService().signIn(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );
                              if (regUser != null) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => const HomePage()),
                                );
                              }
                            }
                            setState(() => isLoading = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDD6937), 
                          ),
                          child: signUp
                              ? const Text('Sign Up', style: TextStyle(color: Colors.white))
                              : const Text('Sign In', style: TextStyle(color: Colors.white)),
                        ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        signUp = !signUp;
                      });
                    },
                    child: signUp
                        ? const Text('Have an account? Sign In', style: TextStyle(color: Color(0xFFC24914)))
                        : const Text('Create an account', style: TextStyle(color: Color(0xFFC24914))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class FirebaseAuthService {
  final FirebaseAuth _fbAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign In Function
  Future<User?> signIn({String? email, String? password}) async {
    try {
      UserCredential uCred = await _fbAuth.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      return uCred.user;
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.message}", gravity: ToastGravity.TOP);
      return null;
    } catch (e) {
      Fluttertoast.showToast(msg: "Unknown error occurred", gravity: ToastGravity.TOP);
      return null;
    }
  }

  Future<User?> signUp({String? email, String? password, String? username}) async {
    try {
      print("🟡 Signing up user...");
      UserCredential uCred = await _fbAuth.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      print("✅ Firebase Authentication Success!");

      User? user = uCred.user;
      if (user != null) {
        String uid = user.uid;
        print("🟡 User UID: $uid");


        await _firestore.collection("users").doc(uid).set({
          "username": username ?? "New User",
          "email": email,
          "profilePicture": "",
          "favourites": {}, 
          "selectedFoods": {}, 
          "savedRecipes": [],
        }).then((_) {
          print("✅ User successfully saved in Firestore: $uid");
        }).catchError((error) {
          print("❌ Firestore Write Error: $error");
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException: ${e.message}");
      Fluttertoast.showToast(msg: "Firebase Auth Error: ${e.message}", gravity: ToastGravity.TOP);
      return null;
    } catch (e) {
      print("❌ Unknown Error: $e");
      Fluttertoast.showToast(msg: "Unknown error occurred", gravity: ToastGravity.TOP);
      return null;
    }
  }
}