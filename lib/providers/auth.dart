// Dart
import 'dart:convert';
// Flutter
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
// Models
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token; // token typically expires
  DateTime _expiryDate;
  String _userId;

  bool get isAuth {
    // If we have a token and the token didn't expire, then the user is authenticated
    return token != null;
  }

  String get token {
    // Token Authentication
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  // AUTHENTICATION
  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    String apiKey = "AIzaSyBZGfRd9oFggAGt796eaBb5jCpQOg_0NlA";
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=" +
            apiKey;
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            "email": email,
            "password": password,
            "returnSecureToken": true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      // Check responseData for and error key
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken']; // Set Token
      _userId = responseData['localId']; // Set Local Id
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']), // Parse String Value in Response Key to int
        ),
      );
      notifyListeners(); // Update UI
    } catch (error) {
      // Will catch if response contains error status
      throw (error);
    }
  }

  // SIGN UP NEW USER
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp'); // returns the future
  }

  // SIGN IN EXISTING USER
  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
