import 'package:signalr_flutter_chat/chat_model.dart';
import 'package:signalr_flutter_chat/database_service.dart';
import 'package:signalr_flutter_chat/socket_service.dart';

class ChatDatabase {
  static Future<List<UserModel>> getUsers() async {
    final db = await DatabaseService.instance.internalDatabase;
    var request = '''
    SELECT * FROM ${DatabaseService.instance.users} 
    WHERE name != ?
  ''';

    var res = await DatabaseService.instance
        .rawQuery(db, request, [SocketService.instance.username]);
    return res.isEmpty ? <UserModel>[] : userModelFromJson(res);
  }

  static Future<List<UserModel>> getUserByName(String name) async {
    final db = await DatabaseService.instance.internalDatabase;
    var request =
        '''Select * from ${DatabaseService.instance.users} where name = ?''';

    var res = await DatabaseService.instance.rawQuery(db, request, [name]);
    return res.isEmpty ? <UserModel>[] : userModelFromJson(res);
  }

  static Future<List<ChatModel>> getChat({required String recBy}) async {
    final db = await DatabaseService.instance.internalDatabase;
    var request =
        '''Select * from ${DatabaseService.instance.chats} where (sendBy = '$recBy' AND recBy = '${SocketService.instance.username}') OR (recBy = '$recBy' AND sendBy = '${SocketService.instance.username}') ORDER BY createdAt DESC''';

    var res = await DatabaseService.instance.rawQuery(db, request);
    return res.isEmpty ? <ChatModel>[] : chatModelFromJson(res);
  }

  static Future<void> insertUser({required String name}) async {
    final db = await DatabaseService.instance.internalDatabase;

    var request =
        '''Select * from ${DatabaseService.instance.users} where name = ?''';
    var resA = await DatabaseService.instance.rawQuery(db, request);

    if (resA.isEmpty) {
      await DatabaseService.instance
          .insert(db, DatabaseService.instance.users, {"name": name});
    }
  }

  static Future<ChatModel?> insertSocketChat({required Map model}) async {
    // model = {
    //     sendBy: username,
    //     recBy: username,
    //     message: message,
    //     createdAt: new Date(),
    //   }

    if (model['sendBy'] != null && model['recBy'] != null) {
      ChatModel chatModel;
      model['sendBy'] = model['sendBy'];

      final userRes = await getUserByName(model['sendBy']!);
      if (userRes.isEmpty) {
        await insertUser(name: model['sendBy']!);
      }

      model['recBy'] = model['recBy'];
      final recRes = await getUserByName(model['recBy']!);
      if (recRes.isEmpty) {
        await insertUser(name: model['recBy']!);
      }

      model['createdAt'] =
          DateTime.parse(model['createdAt']!).toLocal().toString();

      chatModel = ChatModel.fromJson(model);
      final db = await DatabaseService.instance.internalDatabase;
      var parameter = chatModel.toAddJson();

      var res = await DatabaseService.instance
          .insert(db, DatabaseService.instance.chats, parameter);

      chatModel.id = res;

      return chatModel;
    } else {
      return null;
    }
  }
}
