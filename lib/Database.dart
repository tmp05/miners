import 'dart:async';
import 'dart:io';

import 'package:flutter_app/workersdata.dart';
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
        });
  }

  newClient(workersdata newClient) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Workers");
    int id = table.first["id"];
    //insert to the table using the new id
    print(id);
    print(newClient);
    var raw = await db.rawInsert(

   //     "INSERT Into Workers (id,lastbeat,hr,hr2,offline,comment)"
   //         " VALUES (?,?,?,?,?,?)",
   //     [newClient.id, newClient.lastBeat, newClient.hr, newClient.hr2,(newClient.offline)? 1 : 0, newClient.comment.toString()]);
             "INSERT Into Workers (id,id_worker, lastbeat,hr,hr2,offline,date)"
                 " VALUES (?,?,?,?,?,?,?)",
             [id,newClient.id, newClient.lastBeat, newClient.hr, newClient.hr2,(newClient.offline)? 1 : 0,newClient.date]);
    print(raw);
    return raw;
  }

  blockOrUnblock(workersdata client) async {
    final db = await database;
    workersdata blocked = workersdata(
        id: client.id,
        lastBeat: client.lastBeat,
        hr: client.hr,
        hr2: client.hr2,
        offline: !client.offline,
        comment: client.comment);
    var res = await db.update("Workers", blocked.toMap(),
        where: "id = ?", whereArgs: [client.id]);
    return res;
  }

  updateClient(workersdata newClient) async {
    final db = await database;
    var res = await db.update("Workers", newClient.toMap(),
        where: "id = ?", whereArgs: [newClient.id]);
    return res;
  }

  getClient(int id) async {
    final db = await database;
    var res = await db.query("Workers", where: "id = ?", whereArgs: [id]);
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

  Future<List<workersdata>> getAllClients() async {
    final db = await database;
    var res = await db.query("Workers");
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