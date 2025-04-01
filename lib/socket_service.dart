import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService instance = SocketService._();
  factory SocketService() => instance;
  SocketService._();

  final serverUrl =
      "http://localhost:8080"; // Update to match your Node.js server

  late IO.Socket socket;

  void initialize() {
    print("Connecting to server: $serverUrl");

    socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({
              'token':
                  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InByaXllc2gxMTEiLCJpYXQiOjE3NDM1MTM1NjAsImV4cCI6MTc0MzU5OTk2MH0.yUNpvb8Yrb21jHjOos8slKpeq9ndLV40QEudSQAGkiE'
            })
            .disableAutoConnect()
            .build());

    socket.connect();

    socket.onConnect((_) {
      print("Connected to Socket.io Server: ${socket.id}");
    });

    socket.on("receive-message", (data) {
      print("New Message Received: $data");
      print(data.runtimeType);
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

  void sendMessage(String message, String selectedUser) {
    print("Sending Message: $message to $selectedUser");
    socket
        .emit("send-message", {"recipient": selectedUser, "message": message});
  }
}
