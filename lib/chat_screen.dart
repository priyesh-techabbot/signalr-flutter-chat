import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:signalr_flutter_chat/chat_database.dart';
import 'package:signalr_flutter_chat/chat_model.dart';
import 'package:signalr_flutter_chat/socket_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _SocketChatScreenState();
}

class _SocketChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();

  RxList<UserModel> users = RxList.empty();
  RxList<ChatModel> chats = RxList.empty();
  Rxn<UserModel> selectedUser = Rxn();

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    SocketService.instance.initialize();
    getUsers();
    SocketService.instance.chatId.listen(
      (p0) {
        getUsers();
        getChat();
      },
    );
    super.initState();
  }

  void getUsers() {
    ChatDatabase.getUsers().then(
      (value) {
        users.value = value;

        if (selectedUser.value != null &&
            users.where((p0) => p0.name == selectedUser.value!.name).isEmpty) {
          selectedUser.value = null;
        }
      },
    );
  }

  void getChat() {
    if (selectedUser.value != null) {
      ChatDatabase.getChat(recBy: selectedUser.value!.name).then(
        (value) {
          chats.value = value;
        },
      );
    }
  }

  TextEditingController usernameCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SocketService.instance.username),
        actions: [
          IconButton(
            onPressed: () {
              usernameCont.clear();
              Get.dialog(Dialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: usernameCont,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey[800]),
                          hintText: "new username",
                          fillColor: Colors.purple[50],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (usernameCont.text.trim().isNotEmpty) {
                          await ChatDatabase.insertUser(
                              name: usernameCont.text.trim());
                          Get.back();
                          getUsers();
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
              ));
            },
            icon: const Icon(
              Icons.add_circle_outline,
            ),
          ),
        ],
      ),
      body: Obx(
        () => users.isEmpty
            ? const Center(child: Text("No Users Found"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: users.map(
                        (e) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                if (selectedUser.value?.name != e.name) {
                                  selectedUser.value = e;
                                  getChat();
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    selectedUser.value?.name != e.name
                                        ? WidgetStateProperty.all<Color>(
                                            Colors.white)
                                        : WidgetStateProperty.all<Color>(
                                            Colors.blue[200]!),
                              ),
                              child: Text(e.name),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (selectedUser.value != null) ...[
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(20),
                        itemBuilder: (context, index) {
                          var data = chats[index];
                          bool isSender =
                              data.sendBy == SocketService.instance.username;
                          return Align(
                            alignment: isSender
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isSender
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints:
                                      BoxConstraints(maxWidth: Get.width / 1.5),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(data.message),
                                ),
                                Text(
                                  data.createdAt,
                                  style: TextStyle(fontSize: 8),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 20),
                        itemCount: chats.length,
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              hintStyle: TextStyle(color: Colors.grey[800]),
                              hintText: "Type message",
                              fillColor: Colors.purple[50],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (controller.text.trim().isNotEmpty) {
                              final message =
                                  await ChatDatabase.insertSocketChat(model: {
                                'sendBy': SocketService.instance.username,
                                'recBy': selectedUser.value!.name,
                                'message': controller.text.trim(),
                                'createdAt': DateTime.now().toString(),
                              });
                              if (message != null) {
                                chats.insert(0, message);
                                await SocketService.instance.sendMessage(
                                    message.message, message.recBy);
                                controller.clear();
                                scrollController.jumpTo(0);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                          ),
                          child: const Icon(Icons.send, size: 28),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                  const SafeArea(
                    top: false,
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
      ),
    );
  }
}
