// Dart
import 'dart:convert';
// Flutter
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token; // token typically expires
  DateTime _expiryDate;
  String _userId;

  Future<void> signup(String email, String password) async {
    String apiKey = "AIzaSyBZGfRd9oFggAGt796eaBb5jCpQOg_0NlA";
    String url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" +
            apiKey;
    final response = await http.post(
      url,
      body: jsonEncode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    print(json.decode(response.body));
  }
}
