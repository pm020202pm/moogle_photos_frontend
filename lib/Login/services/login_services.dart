import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../const.dart';

final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
String requestOtpUrl = '$baseUrl/auth/requestotp';
String loginUrl = '$baseUrl/auth/login';
String registerUrl = '$baseUrl/auth/register';

class LoginServices{

  static Future<int> sendOTP(String emailId, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(requestOtpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': emailId
        }),
      );
      return response.statusCode;
    } catch (e) {
      debugPrint('Error in sending request, $e');
      return 500;
    }
  }

  static Future<http.Response?> loginUser(String emailId, String name, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': emailId.toLowerCase(),
          'name' : name.toUpperCase(),
          'otp' : otp
        }),
      );
      return response;
    } catch (e) {
      debugPrint('Error in sending request');
      return null;
    }
  }

  static Future<http.Response?> getUser(String emailId) async {
    try{
      final response = await http.get(
        Uri.parse('$baseUrl/auth/user/$emailId'),
        headers: {
          'Content-Type': 'application/json',
        }
      );
      return response;
    }
    catch(e) {
      return null;
    }
  }

  static Future<String?> fetchUserEmail(String accessToken) async {
    final url = Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['email']; // You can return more info like name, picture, etc.
    } else {
      debugPrint('Failed to fetch user info: ${response.body}');
      return null;
    }
  }

  static Future<String> getAccessTokenFromBackend(String refreshToken) async {
    final url = Uri.parse('$baseUrl/get-access-token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['accessToken'];
    } else {
      throw Exception('Failed to get access token');
    }
  }


}

void errorSnackMsg(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red),
  );
}

void successSnackMsg(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.green),
  );
}