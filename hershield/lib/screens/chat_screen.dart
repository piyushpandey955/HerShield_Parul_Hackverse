// import 'package:flutter/material.dart';
// import '../services/chatbot_service.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, String>> _messages = [];
//   final ChatbotService _chatbotService = ChatbotService();

//   void _sendMessage() async {
//     final userMessage = _controller.text.trim();
//     if (userMessage.isEmpty) return;

//     setState(() {
//       _messages.add({'sender': 'user', 'message': userMessage});
//     });
//     _controller.clear();

//     try {
//       final botResponse = await _chatbotService.sendMessage(userMessage);
//       setState(() {
//         _messages.add({'sender': 'bot', 'message': botResponse});
//       });
//     } catch (e) {
//       setState(() {
//         _messages.add({'sender': 'bot', 'message': 'Error: Unable to fetch response.'});
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Arya AI'),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 final isUser = message['sender'] == 'user';

//                 return Align(
//                   alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: isUser ? Colors.blue[100] : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(message['message'] ?? ''),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'Type your message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ChatbotService _chatbotService = ChatbotService();
  bool _isTyping = false; // To show typing indicator

  void _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'message': userMessage});
      _isTyping = true; // Start typing indicator
    });
    _controller.clear();

    try {
      final botResponse = await _chatbotService.sendMessage(userMessage);
      setState(() {
        _messages.add({'sender': 'bot', 'message': botResponse});
        _isTyping = false; // Stop typing indicator
      });
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'message': 'Error: Unable to fetch response.'});
        _isTyping = false; // Stop typing indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arya AI'),
        centerTitle: true,
        // backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length + (_isTyping ? 1 : 0), // Add 1 for the typing indicator
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  // Show typing indicator
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 10),
                        Text("Arya AI is typing...", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final message = _messages[index];
                final isUser = message['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      message['message'] ?? '',
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  // backgroundColor: Colors.deepPurpleAccent,
                  elevation: 4,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}