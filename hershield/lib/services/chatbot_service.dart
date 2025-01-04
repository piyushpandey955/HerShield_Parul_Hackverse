import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  final String apiUrl = 'https://hershield-arya-backend.onrender.com/chat'; // Replace with your public URL

  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('response')) {
          return data['response']; // Extract the 'response' field
        } else {
          return 'Error: Unexpected response format.';
        }
      } else {
        return 'Error: Received status code ${response.statusCode}.';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}