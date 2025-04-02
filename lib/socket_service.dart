import 'package:get/get.dart';
import 'package:signalr_flutter_chat/chat_database.dart';
import 'package:signalr_flutter_chat/chat_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService instance = SocketService._();
  factory SocketService() => instance;
  SocketService._();

  final serverUrl = "http://localhost:8080";

  late IO.Socket socket;

  late String username;
  late String access_token;
  RxInt chatId = RxInt(0);

  void initialize() {
    print("Connecting to server: $serverUrl");

    socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': access_token})
            .disableAutoConnect()
            .build());

    socket.connect();

    socket.onConnect((_) {
      print("Connected to Socket.io Server: ${socket.id}");
    });

    socket.on("receive-message", (data) {
      print("New Message Received: $data");
      print(data.runtimeType);
      print(data is Map);

      if (data is Map) {
        ChatDatabase.insertSocketChat(model: data).then(
          (value) {
            if (value != null) {
              chatId.value = value.id;
            }
          },
        );
      }
    });

    socket.onDisconnect((_) {
      print("Disconnected from Server");
    });

    socket.onError(
      (data) {
        print("onError: $data");
        print(data.runtimeType);
      },
    );
  }

  Future<void> sendMessage(String message, String recBy) async {
    socket.emit("send-message", {"recipient": recBy, "message": message});
  }
}
