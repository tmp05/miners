import 'dart:convert';

wallets clientFromJson(String str) {
  final jsonData = json.decode(str);
  return wallets.fromMap(jsonData);
}

String clientToJson(wallets data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class wallets{
  String id;
  String alias;
  String comment;
  int online;
  int offline;

  wallets({this.id,this.alias,this.comment,this.online,this.offline});

  factory wallets.fromMap(Map<String, dynamic> json) => new wallets(
      id: json["id"],
      alias: json["alias"],
      comment: json["comment"],
      online: json["online"],
      offline: json["offline"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "alias": alias,
    "comment": comment,
    "online": online,
    "offline": offline,
  };
}

