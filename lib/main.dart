import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  Map<String, String> users = {};
  String? currentUserName;

  List<String> messages = [];
  String? selectedUser;

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    SocketService.instance.initalize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        users = {};
        users.addAll(SocketService.instance.userList.value ?? {});
        currentUserName = SocketService.instance.userList.value?.keys
            .toList()
            .firstWhereOrNull(
                (element) => element == SocketService.instance.currentId);

        if (currentUserName != null) {
          users.removeWhere((key, value) => key == currentUserName);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(currentUserName != null
                ? SocketService.instance.userList.value![currentUserName]!
                : 'SignalR Chat'),
          ),
          body: users.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            var data = users.values.toList()[index];
                            return InkWell(
                              onTap: () {
                                selectedUser = data;
                                messages.clear();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(data.toString()),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: users.keys.length,
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  return Text(messages[index]);
                                },
                                itemCount: messages.length,
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 5);
                                },
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: TextField(controller: controller)),
                                IconButton(
                                  onPressed: () {
                                    if (controller.text.trim().isNotEmpty) {
                                      SocketService.instance
                                          .sendMessage(controller.text.trim());
                                    }
                                  },
                                  icon: const Icon(Icons.send),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : null,
        );
      },
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
