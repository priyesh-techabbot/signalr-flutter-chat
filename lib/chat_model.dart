List<UserModel> userModelFromJson(List<Map<String, dynamic>> str) =>
    List<UserModel>.from(str.map((x) => UserModel.fromJson(x)));

List<ChatModel> chatModelFromJson(List<Map<String, dynamic>> str) =>
    List<ChatModel>.from(str.map((x) => ChatModel.fromJson(x)));

class UserModel {
  String name;

  UserModel({
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json["name"],
      );

  Map<String, dynamic> toAddJson() => {
        "name": name,
      };
}

class ChatModel {
  int id;
  String sendBy;
  String recBy;
  String message;
  String createdAt;

  ChatModel({
    required this.id,
    required this.sendBy,
    required this.recBy,
    required this.message,
    required this.createdAt,
  });

  factory ChatModel.fromJson(Map json) => ChatModel(
        id: json["id"] ?? -1,
        sendBy: json["sendBy"],
        recBy: json["recBy"],
        message: json["message"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toAddJson() => {
        "sendBy": sendBy,
        "recBy": recBy,
        "message": message,
        "createdAt": createdAt,
      };
}
