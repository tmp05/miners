import 'dart:async';
import 'dart:io';

import 'package:flutter_app/workersdata.dart';
import 'package:flutter_app/workersinfo.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'constants.dart' as Constants;

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    print(documentsDirectory.path);
    String path = join(documentsDirectory.path, Constants.Database_name);
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
           await db.execute("CREATE TABLE Workers ("
              "id INTEGER PRIMARY KEY,"
              "id_worker TEXT,"
              "lastBeat INTEGER,"
              "hr REAL,"
              "hr2 REAL,"
              "offline INTEGER,"
              "date INTEGER"
              ")");
           await db.execute("CREATE TABLE WorkersInfo ("
               "id TEXT PRIMARY KEY,"
               "comment TEXT,"
               "wallet TEXT"
               ")");
        });
  }

  newClient(workersdata newClient) async {
    final db = await database;
    //get the biggest id in the table
//    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Workers");
//    print(table);
//    int id = table.first["id"];
//    print("trying to insert #"+id.toString());
       //insert to the table using the new id
    print(newClient);
    var raw = await db.rawInsert(

   //     "INSERT Into Workers (id,lastbeat,hr,hr2,offline,comment)"
   //         " VALUES (?,?,?,?,?,?)",
   //     [newClient.id, newClient.lastBeat, newClient.hr, newClient.hr2,(newClient.offline)? 1 : 0, newClient.comment.toString()]);
             "INSERT Into Workers (id_worker, lastbeat,hr,hr2,offline,date)"
                 " VALUES (?,?,?,?,?,?)",
             [newClient.id_worker, newClient.lastBeat, newClient.hr, newClient.hr2,(newClient.offline)? 1 : 0,newClient.date]);
    print(raw);
    return raw;
  }

  newWorker(workersinfo newClient) async {
    final db = await database;
    var res = await db.query("WorkersInfo", where: "id = ?", whereArgs: [newClient.id]);
     if (!res.isNotEmpty){
      var raw = await db.rawInsert(
          "INSERT Into WorkersInfo (id, comment,wallet)"
              " VALUES (?,?,?)",
          [newClient.id, newClient.comment, newClient.wallet]);
      print(raw);
      return raw;
    }

  }

  blockOrUnblock(workersdata client) async {
    final db = await database;
    workersdata blocked = workersdata(
        id: client.id,
        lastBeat: client.lastBeat,
        hr: client.hr,
        hr2: client.hr2,
        offline: !client.offline);
    var res = await db.update("Workers", blocked.toMap(),
        where: "id = ?", whereArgs: [client.id]);
    return res;
  }

  updateWorker(String id, String comment) async {
    final db = await database;
    var res = await db.rawUpdate("UPDATE WorkersInfo SET comment = '"+comment+"' where id ='"+id+"'");
    return res;
  }

  getClient(int id) async {
    final db = await database;
    var res = await db.query("WorkersInfo", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? workersdata.fromMap(res.first) : null;
  }

  Future<List<workersdata>> getBlockedClients() async {
    final db = await database;

    print("works");
    // var res = await db.rawQuery("SELECT * FROM Workers WHERE blocked=1");
    var res = await db.query("Workers", where: "blocked = ? ", whereArgs: [1]);

    List<workersdata> list =
    res.isNotEmpty ? res.map((c) => workersdata.fromMap(c)).toList() : [];
    return list;
  }
  //SELECT MAX(id)+1 as id FROM Workers

  Future<List<workersdata>> getAllClients() async {
    final db = await database;
    var res = await db.rawQuery("SELECT WorkersInfo.comment, Workers.* "
        "    FROM WorkersInfo LEFT JOIN Workers"
        "    ON  WorkersInfo.id = Workers.id_worker LEFT JOIN"
        "    (SELECT MAX(Workers.date) AS Last_Date, Workers.id_worker"
        "    FROM Workers"
        "    GROUP BY Workers.id_worker) new_Workers"
        "    ON WorkersInfo.id = new_Workers.id_worker"
        "    WHERE Workers.date = Last_Date");
    List<workersdata> list =
    res.isNotEmpty ? res.map((c) => workersdata.fromMap(c)).toList() : [];
    return list;
  }

  deleteClient(int id) async {
    final db = await database;
    return db.delete("Workers", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from Workers");
  }
}