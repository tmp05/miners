import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app/workersdata.dart';
import 'package:flutter_app/workersinfo.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/Database.dart';

class workerslist extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
     return workerslistState();
  }
}

class workerslistState extends State<workerslist>{

  List<workersdata> data = [];

  var timezoneOffset = new DateTime.now().timeZoneOffset;

  List <Widget> _buildList() {
    return data.map((workersdata w)=>ListTile(
      title : Text(w.id_worker),
      subtitle : Text(DateTime.fromMillisecondsSinceEpoch(w.date).toString()),
      leading : CircleAvatar(
          backgroundColor: ((w.offline==false&&(DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(w.date)).inMinutes<15))?Colors.lightBlue:Colors.red),
          child:Text(((w.offline==false&&(DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(w.date)).inMinutes<15))?"ok":"!"))),
      trailing : Text("hr="+w.hr.toString()+",hr2="+w.hr2.toString()),
      onTap: () => onTapped(w),
    )).toList();
  }

  @override
  void initState(){
    super.initState();
    _refreshworkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Mine workers'),
        ),
        body: Container(
            child: ListView(
              children: _buildList(),

            )
        ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: ()=>_refreshworkers(),
      ),
    );
  }

  void onTapped(workersdata w) {
    Navigator.pushNamed(context, '/worker', arguments: w);
  }


  Future _loadworkers() async {
    final response = await http.get('https://zel.2miners.com/api/accounts/t1NaaN8fjEhKmCvZ5YXEVxWdXass6mMNRRh');
    if (response.statusCode==200){
       var alldata = (json.decode(response.body) as Map)['workers'] as Map<String,dynamic> ;
       var date = new DateTime.now().millisecondsSinceEpoch;
        alldata.forEach((String key,dynamic val) async {
         print(key);
         print(val);
         var record = workersdata(id_worker:key,lastBeat:val["lastBeat"], hr:val["hr"].toDouble(), hr2:val["hr2"].toDouble(), offline:val["offline"],date:date);
         await DBProvider.db.newClient(record);
         var record_w = workersinfo(id:key,comment:"", wallet:"");
         await DBProvider.db.newWorker(record_w);
       });
    }
  }

  _refreshworkers() async {
    await _loadworkers();
    await DBProvider.db.getAllClients().then((wDatabaseList)=>{
      setState(() {
        data = wDatabaseList;
      })
    });

  }

}