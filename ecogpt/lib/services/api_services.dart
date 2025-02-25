import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class ApiServices {
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}/user_login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    print("🔹 Raw Response: ${response.body}");

    try {
      final decodedResponse = jsonDecode(response.body);

      if (decodedResponse is int) {
        return {
          "status": "error",
          "message": "Unexpected int response: $decodedResponse",
        };
      } else if (decodedResponse is List) {
        return {"status": "success", "user_data": decodedResponse};
      } else if (decodedResponse is Map<String, dynamic>) {
        return decodedResponse;
      } else {
        return {"status": "error", "message": "Unknown response type"};
      }
    } catch (e) {
      return {"status": "error", "message": "Error parsing response: $e"};
    }
  }
}
