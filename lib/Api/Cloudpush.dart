import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// var ip = 'https://prasath.pythonanywhere.com';
// var ip = "http://127.0.0.1:8000";
var ip = 'https://prasath.pythonanywhere.com';
Future<void> sendPushNotification(
    {required registration_token,
    required title,
    required body,
    required email,
    required state,
    required reason}) async {
  print(email);
  print(state);
  final url = Uri.parse('${ip}/send_push_notification/');
  final data = {
    'registration_token': registration_token,
    'title': title.toString(),
    'body': body,
    'email': email,
    'state': state,
    'reason': reason
  };
  print(data);
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully!');
      print('Response: ${response.body}');
    } else {
      print('Failed to send notification');
      print('Status code: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
