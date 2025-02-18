import 'package:flutter/material.dart';
import 'package:flutterproject/services/openai_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'chat_page.dart';

class ChatGPTScreen extends StatefulWidget {
  @override
  _ChatGPTScreenState createState() => _ChatGPTScreenState();
}

class _ChatGPTScreenState extends State<ChatGPTScreen> {
  final OpenAIService openAIService = OpenAIService();
  String? foodAnalysis;
  File? selectedImage;
  bool isLoading = false;

  Future<void> _analyzeFood() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      isLoading = true;
      foodAnalysis = null;
      selectedImage = File(pickedFile.path);
    });

    String? result = await openAIService.analyzeFood("What food is in this image?");

    setState(() {
      foodAnalysis = result;
      isLoading = false;
    });
  }

  Widget _formattedAnalysisText(String analysis) {
    List<TextSpan> spans = [];
    List<String> lines = analysis.split("\n");

    for (String line in lines) {
      if (line.startsWith("##")) {
        spans.add(
          TextSpan(
            text: line.replaceAll("##", "").trim() + "\n\n",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC24914)),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: line + "\n",
            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
          ),
        );
      }
    }

    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(children: spans, style: TextStyle(fontSize: 16, color: Colors.black)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7EBCD), 
      appBar: AppBar(
        title: Text(
          "Food Analysis",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFDD6937), 
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center( 
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _analyzeFood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDD6937), 
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Upload & Analyze", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              SizedBox(height: 20),

              if (selectedImage == null && foodAnalysis == null) ...[
                Text(
                  "Analysis Result:",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFC24914)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "No analysis yet. Upload an image.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Expanded(
                  child: SingleChildScrollView( 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (selectedImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImage!,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        SizedBox(height: 20),

                        Text(
                          "Analysis Result:",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFC24914)),
                        ),
                        SizedBox(height: 10),

                        isLoading
                            ? CircularProgressIndicator(color: Color(0xFFDD6937))
                            : Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 253, 253, 253), 
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: _formattedAnalysisText(foodAnalysis!), 
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage()),  
    );
  },
  backgroundColor: Color(0xFFDD6937),
  child: Icon(Icons.chat, color: Colors.white),
),

    );
  }
}
