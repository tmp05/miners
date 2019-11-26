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
    double datedouble = new DateTime.now().millisecondsSinceEpoch/1000.toInt();
    int dateint = datedouble.toInt();
    alldata.forEach((String key, dynamic val) async {
      var record = workersdata(id_worker: key,
          lastBeat: val["lastBeat"],
          hr: val["hr"].toDouble(),
          hr2: val["hr2"].toDouble(),
          offline: val["offline"],
          date: dateint);
      await DBProvider.db.newClient(record);
      var record_w = workersinfo(id: key, comment: "", wallet: id);
      await DBProvider.db.newWorker(record_w);
    });
    return true;
  }
  else {return false;}
}

Future<bool> GetResponseForAll(List<wallets> list) async{
  for(var item in list ) {
    GetResponse(item.alias, item.id);
  }
  return true;
}

GetServers() async{
  final response2 = await http.get("https://apidoc.2miners.com/2miners_api.json");
  if (response2.statusCode == 200) {
  var alldata = (json.decode(response2.body) as Map)['servers'] ;
  var _data = new List<String>();
    for (var name in alldata) {
      var _tempString = name["url"].toString();
      _tempString = _tempString.substring(0,_tempString.length-4);
      _data.add(_tempString);
    }

   return _data;
  }
}