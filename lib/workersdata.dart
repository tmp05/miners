import 'dart:convert';

workersdata clientFromJson(String str) {
  final jsonData = json.decode(str);
  return workersdata.fromMap(jsonData);
}

String clientToJson(workersdata data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class workersdata{
  int id;
  String id_worker;
  int lastBeat;
  double hr;
  double hr2;
  bool offline;
  String comment;
  int date;

  workersdata({this.id,this.id_worker, this.lastBeat, this.hr, this.hr2, this.offline, this.comment, this.date});

  factory workersdata.fromMap(Map<String, dynamic> json) => new workersdata(
    id: json["id"],
    id_worker: json["id_worker"],
    lastBeat: json["lastBeat"],
    hr: json["hr"],
    hr2: json["hr2"],
    offline: json["offline"] == 1,
    comment: json["comment"],
    date: json["date"]
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "id_worker": id_worker,
    "lastBeat": lastBeat,
    "hr": hr,
    "hr2": hr2,
    "offline": offline,
    "comment": comment,
    "date": date,
  };
}

