import 'package:get/get_rx/get_rx.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SocketService {
  static final SocketService instance = SocketService._();
  factory SocketService() => instance;
  SocketService._();

  final serverUrl = "https://192.168.1.133:7027/chathub";

  Rxn<Map<String, String>> userList = Rxn();
  RxList<List<String>> messages = RxList();
  String? currentId;
  late HubConnection hubConnection;

  bool registered = false;

  void initalize() async {
    print("serverUrl => $serverUrl");
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();

    await hubConnection.start();

    currentId = hubConnection.connectionId;

    print("Connection => ${hubConnection.connectionId}");
    print("State => ${hubConnection.state}");

    hubConnection.on(
      "ReceiveMessage",
      (arguments) {
        print("on ReceiveMessage");
        print(arguments);
        print(arguments.runtimeType);
        if (arguments != null && arguments.isNotEmpty) {
          messages.add(arguments as List<String>);
        }
      },
    );

    hubConnection.on(
      "UpdateUserList",
      (arguments) {
        print("on UpdateUserList");
        print(arguments);

        if (arguments != null && arguments.isNotEmpty) {
          userList.value = arguments.first as Map<String, String>;

          registerUser();
        }
      },
    );

    hubConnection.stateStream.listen(
      (event) {
        print("hubConnection.state => $event");
      },
    );

    hubConnection.onclose(
      ({error}) {
        print("hubConnection.onclose");
        print(error);
      },
    );
  }

  void registerUser() {
    if (userList.value != null && currentId != null && !registered) {
      registered = true;
      userList.value![currentId!] =
          "Guest_${userList.value!.entries.length + 1}";
      hubConnection.send("UpdateUserList", args: [userList.value!]);
    }
  }

  void sendMessage(String message) {
    hubConnection.send("ReceiveMessage", args: [currentId!, message]);
  }
}
