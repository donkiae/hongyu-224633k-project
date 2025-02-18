import 'package:flutter/material.dart';
import 'package:flutterproject/services/chat_api_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatAPIService chatAPIService = ChatAPIService();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  bool isLoading = false;

  void _sendMessage(String userMessage) async {
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "content": userMessage});
      isLoading = true;
    });

    String? response = await chatAPIService.askChatGPT(userMessage);

    setState(() {
      if (response != null) {
        messages.add({"role": "bot", "content": response});
      } else {
        messages.add({"role": "bot", "content": "Sorry, something went wrong."});
      }
      isLoading = false;
    });
  }

  void _showQuickQuestions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Quick Questions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFC24914)),
              ),
              SizedBox(height: 15),
              _quickQuestionTile("How many calories in chicken rice?"),
              _quickQuestionTile("Give me a meal plan for weight loss in 1 month."),
              _quickQuestionTile("What are the benefits of eating eggs?"),
              _quickQuestionTile("Suggest a high-protein vegetarian meal."),
              _quickQuestionTile("What foods are best for muscle growth?"),
            ],
          ),
        );
      },
    );
  }

  Widget _quickQuestionTile(String question) {
    return ListTile(
      title: Text(question, style: TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context); 
        _sendMessage(question);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7EBCD),
      appBar: AppBar(
        title: Text("Need Help?", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFDD6937),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUser = messages[index]["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isUser ? Color(0xFFDD6937) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      messages[index]["content"]!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading) CircularProgressIndicator(color: Color(0xFFDD6937)),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                // Button for Quick Questions
                IconButton(
                  icon: Icon(Icons.lightbulb, color: Color(0xFFDD6937)),
                  onPressed: _showQuickQuestions,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask something...",
                      filled: true,
                      fillColor: Color.fromARGB(255, 234, 145, 113),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    _sendMessage(_controller.text.trim());
                    _controller.clear();
                  },
                  backgroundColor: Color(0xFFDD6937),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
