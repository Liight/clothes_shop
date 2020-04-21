// Dart
import 'dart:convert';
import 'dart:async';
// Flutter
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Models
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token; // token typically expires
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

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
          seconds: int.parse(responseData[
              'expiresIn']), // Parse String Value in Response Key to int
        ),
      );
      autoLogout(); // Start auto timer to logout
      notifyListeners(); // Update UI

      // Store Token
      final prefs = await SharedPreferences
          .getInstance(); // Returns future of shared prefs
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      ); // can use json encode to encode more complex data maps
      prefs.setString('userData', userData);
    } catch (error) {
      // Will catch if response contains error status
      throw (error);
    }
  }

  // Checks for valid token and auto logs in user if one is found
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    // Checks for stored data
    if (!prefs.containsKey('userData')) {
      return false;
    }
    // Extract and Store data
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    // Checks if expiryDate is in the past
    if (expiryDate.isAfter(DateTime.now())) {
      return false;
    }
    // Set Values
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    autoLogout();
    return true;
  }

  // SIGN UP NEW USER
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp'); // returns the future
  }

  // SIGN IN EXISTING USER
  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    _authTimer = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear(); // Purges all data from sharedPreferences on device
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
