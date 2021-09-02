import 'dart:convert';

Chats chatsFromJson(String str) => Chats.fromJson(json.decode(str));

String chatsToJson(Chats data) => json.encode(data.toJson());

class Chats {
  Chats({
    this.connections,
    this.totalChats,
    this.totalRead,
    this.totalUnread,
    this.chat,
    this.lastTime,
  });

  List<String>? connections;
  int? totalChats;
  int? totalRead;
  int? totalUnread;
  List<Chat>? chat;
  String? lastTime;

  factory Chats.fromJson(Map<String, dynamic> json) => Chats(
        connections: List<String>.from(json["connections"].map((x) => x)),
        totalChats: json["total_chats"],
        totalRead: json["total_read"],
        totalUnread: json["total_unread"],
        chat: List<Chat>.from(json["chat"].map((x) => Chat.fromJson(x))),
        lastTime: json["lastTime"],
      );

  Map<String, dynamic> toJson() => {
        "connections": List<dynamic>.from(connections!.map((x) => x)),
        "total_chats": totalChats,
        "total_read": totalRead,
        "total_unread": totalUnread,
        "chat": List<dynamic>.from(chat!.map((x) => x.toJson())),
        "lastTime": lastTime,
      };
}

class Chat {
  Chat({
    this.sender,
    this.recipient,
    this.message,
    this.time,
    this.isRead,
  });

  String? sender;
  String? recipient;
  String? message;
  String? time;
  bool? isRead;

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        sender: json["sender"],
        recipient: json["recipient"],
        message: json["message"],
        time: json["time"],
        isRead: json["isRead"],
      );

  Map<String, dynamic> toJson() => {
        "sender": sender,
        "recipient": recipient,
        "message": message,
        "time": time,
        "isRead": isRead,
      };
}
