import 'dart:async';
import 'dart:io';

import 'package:flutter_app/wallets.dart';
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
           await db.execute("CREATE TABLE Wallets ("
               "id TEXT PRIMARY KEY,"
               "comment TEXT,"
               "alias TEXT,"
               "online TEXT,"
               "count TEXT"
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
     else{
      var raw = await db.rawUpdate(
           "UPDATE  WorkersInfo SET comment = '"+newClient.comment+"', wallet='"+newClient.wallet+"' where id ='"+newClient.id+"'");
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

  newWallet(wallets newClient) async {
    final db = await database;
    var res = await db.query("Wallets", where: "id = ?", whereArgs: [newClient.id]);
    if (res.isEmpty){
      var raw = await db.rawInsert(
          "INSERT Into Wallets (id, comment,alias)"
              " VALUES (?,?,?)",
          [newClient.id, newClient.comment, newClient.alias]);
      print(raw);
      return raw;
    }
    else{
      var res = await db.rawUpdate("UPDATE Wallets SET comment = '"+newClient.comment+"', alias='"+newClient.alias+"' where id ='"+newClient.id+"'");
      return res;
    }

  }

  Future getCountWorkers(wallets newClient) async {
    final db = await database;
    var res = await db.rawQuery("Select count(workersinfo.id) as count FROM WorkersInfo WHERE WorkersInfo.wallet='"+newClient.id+"'");
    res.forEach((row) {
      return row['count'];
    });
 }

  Future<List<wallets>> getOnlineAndCount(wallets newClient) async {
    final db = await database;
    var res = await db.rawQuery("Select Wallet.id, Wallet.alias, Wallet.comment, Onlineworkers.online, Allworkers.count from "
        "      (Select count(Workersdata.id_worker) as online from Wallets"
        "        LEFT JOIN (SELECT WorkersInfo.comment,WorkersInfo.wallet, Workers.*"
        "        FROM WorkersInfo LEFT JOIN Workers"
        "        ON  WorkersInfo.id = Workers.id_worker LEFT JOIN"
        "        (SELECT MAX(Workers.date) AS Last_Date, Workers.id_worker"
        "    FROM Workers"
        "    GROUP BY Workers.id_worker) new_Workers"
        "    ON WorkersInfo.id = new_Workers.id_worker"
        "    WHERE Workers.date = Last_Date) as Workersdata"
        "    on Wallets.id=Workersdata.wallet"
        "    WHERE Workersdata.offline=0 AND Wallets.id='"+newClient.id+"') as Onlineworkers"
        "    LEFT JOIN"
        "    ( Select count(WorkersInfo.id) as count FROM WorkersInfo WHERE WorkersInfo.wallet='"+newClient.id+"' ) as Allworkers on 1=1"
        "    LEFT JOIN"
        "    ( Select *  FROM Wallets WHERE Wallets.id='"+newClient.id+"' ) as Wallet on 1=1");
    List<wallets> list =
    res.isNotEmpty ? res.map((c) =>wallets.fromMap(c)).toList(): [];
    return list;
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

  Future<List<workersdata>> getAllWalletClients(wallets w) async {
    final db = await database;
    var res = await db.rawQuery("SELECT WorkersInfo.comment, Workers.* "
        "    FROM WorkersInfo LEFT JOIN Workers"
        "    ON  WorkersInfo.id = Workers.id_worker LEFT JOIN"
        "    (SELECT MAX(Workers.date) AS Last_Date, Workers.id_worker"
        "    FROM Workers"
        "    GROUP BY Workers.id_worker) new_Workers"
        "    ON WorkersInfo.id = new_Workers.id_worker"
        "    WHERE Workers.date = Last_Date AND WorkersInfo.wallet='"+w.id+"'"
        "    ORDER BY Workers.offline DESC");
    List<workersdata> list =
    res.isNotEmpty ? res.map((c) =>workersdata.fromMap(c)).toList(): [];
    return list;
  }

  Future<List<wallets>> getAllWallets() async {
    final db = await database;
    var res = await db.rawQuery("Select Wallet.id, Wallet.alias, Wallet.comment, Onlineworkers.online, Allworkers.count"
        "        from ( Select *  FROM Wallets  ) as Wallet"
        "    LEFT JOIN       (Select count(Workersdata.id_worker) as online, Wallets.id from Wallets"
        "    LEFT JOIN (SELECT WorkersInfo.comment,WorkersInfo.wallet, Workers.*    FROM WorkersInfo LEFT JOIN Workers"
        "    ON  WorkersInfo.id = Workers.id_worker LEFT JOIN"
        "    (SELECT MAX(Workers.date) AS Last_Date, Workers.id_worker    FROM Workers    GROUP BY Workers.id_worker) new_Workers"
        "    ON WorkersInfo.id = new_Workers.id_worker    WHERE Workers.date = Last_Date) as Workersdata"
        "    on Wallets.id=Workersdata.wallet"
        "    WHERE Workersdata.offline=0"
        "    GROUP BY Wallets.id) as Onlineworkers   on Onlineworkers.id=Wallet.id"
        "    LEFT JOIN    ( Select count(WorkersInfo.id) as count, WorkersInfo.wallet FROM WorkersInfo GROUP BY WorkersInfo.wallet) as Allworkers on Onlineworkers.id=Allworkers.wallet");
    List<wallets> list =
    res.isNotEmpty ? res.map((c) =>wallets.fromMap(c)).toList(): [];
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