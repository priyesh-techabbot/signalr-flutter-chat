import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_flutter_chat/chat_database.dart';
import 'package:signalr_flutter_chat/chat_screen.dart';
import 'package:signalr_flutter_chat/socket_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController controller = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey[800]),
                  hintText: "Your username",
                  fillColor: Colors.purple[50],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (loading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() {
                      loading = true;
                    });

                    try {
                      print('http://localhost:8080/service/login');

                      var res = await http.post(
                        Uri.parse('http://localhost:8080/service/login'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({"username": controller.text.trim()}),
                      );

                      print(res.statusCode);
                      print(res.body);
                      if (res.statusCode == 200) {
                        var deBody = jsonDecode(res.body);
                        if (deBody['data'] != null &&
                            deBody['data']!['access_token'] != null) {
                          SocketService.instance.access_token =
                              deBody['data']!['access_token'];
                          SocketService.instance.username =
                              deBody['data']!['username'];

                              ChatDatabase.insertUser(name: SocketService.instance.username);

                          Get.offAll(const ChatScreen());
                        }
                      }
                    } catch (e, s) {
                      print(e);
                      print(s);
                    }

                    setState(() {
                      loading = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.send, size: 28),
              ),
          ],
        ),
      ),
    );
  }
}
