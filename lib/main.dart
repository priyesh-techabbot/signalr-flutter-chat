import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signalr_flutter_chat/socket_service.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SocketChatScreen(),
    );
  }
}

class SocketChatScreen extends StatefulWidget {
  const SocketChatScreen({super.key});

  @override
  State<SocketChatScreen> createState() => _SocketChatScreenState();
}

class _SocketChatScreenState extends State<SocketChatScreen> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    SocketService.instance.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SocketService.instance.sendMessage('Im good WBU?', 'priyesh222');
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
