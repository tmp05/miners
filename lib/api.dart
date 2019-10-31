import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/Database.dart';
import 'package:flutter_app/workersdata.dart';
import 'package:flutter_app/workersinfo.dart';
import 'package:flutter_app/wallets.dart';

GetResponse(String alias, String id) async{
  final response2 = await http.get(alias+"/api/accounts/"+id);
  if (response2.statusCode == 200) {
    var alldata = (json.decode(response2.body) as Map)['workers'] as Map<
        String,
        dynamic>;
    var date = new DateTime.now().millisecondsSinceEpoch;
    alldata.forEach((String key, dynamic val) async {
      print(key);
      print(val);
      var record = workersdata(id_worker: key,
          lastBeat: val["lastBeat"],
          hr: val["hr"].toDouble(),
          hr2: val["hr2"].toDouble(),
          offline: val["offline"],
          date: date);
      await DBProvider.db.newClient(record);
      var record_w = workersinfo(id: key, comment: "", wallet: id);
      await DBProvider.db.newWorker(record_w);
    });
  }
  return true;
}

GetResponseForAll(List<wallets> list) async{
  for(var item in list ) {
    final response2 = await http.get(item.alias + "/api/accounts/" + item.id);
    if (response2.statusCode == 200) {
      var alldata = (json.decode(response2.body) as Map)['workers'] as Map<
          String,
          dynamic>;
      var date = new DateTime.now().millisecondsSinceEpoch;
      alldata.forEach((String key, dynamic val) async {
        print(key);
        print(val);
        var record = workersdata(id_worker: key,
            lastBeat: val["lastBeat"],
            hr: val["hr"].toDouble(),
            hr2: val["hr2"].toDouble(),
            offline: val["offline"],
            date: date);
        await DBProvider.db.newClient(record);
        var record_w = workersinfo(id: key, comment: "", wallet: item.id);
        await DBProvider.db.newWorker(record_w);
      });
    }
  }
  return true;
}