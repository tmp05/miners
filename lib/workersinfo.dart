import 'dart:convert';

workersinfo clientFromJson(String str) {
  final jsonData = json.decode(str);
  return workersinfo.fromMap(jsonData);
}

String clientToJson(workersinfo data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class workersinfo{
  String id;
  String comment;
  String wallet;

  workersinfo({this.id,this.comment, this.wallet});

  factory workersinfo.fromMap(Map<String, dynamic> json) => new workersinfo(
      id: json["id"],
      comment: json["comment"],
      wallet: json["wallet"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "comment": comment,
    "wallet": wallet,

  };
}
