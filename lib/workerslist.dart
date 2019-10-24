import 'package:flutter/material.dart';
import 'package:flutter_app/workersdata.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class workerslist extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
     return workerslistState();
  }
}

class workerslistState extends State<workerslist>{

  List<workersdata> data = [];

  List <Widget> _buildList() {
    return data.map((workersdata w)=>ListTile(
      title : Text(w.id),
      subtitle : Text(w.comment),
      leading : CircleAvatar(child:Text(w.offline.toString())),
      trailing : Text("hr="+w.hr.toString()+",hr2="+w.hr2.toString()),
      onTap: () => onTapped(w),
    )).toList();
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
        onPressed: ()=>_loadworkers(),
      ),
    );
  }

  void onTapped(workersdata w) {
    Navigator.pushNamed(context, '/worker', arguments: w);
  }

  _loadworkers() async {
    final response = await http.get('https://zel.2miners.com/api/accounts/t1Rvs2AHVwwy9bx3NfA8FHZ1AcxcihqDEQT');
    if (response.statusCode==200){
       var alldata = (json.decode(response.body) as Map)['workers'] as Map<String,dynamic> ;

       var wdataList = List<workersdata>();
       alldata.forEach((String key,dynamic val){
         print(val);
         var record = workersdata(id:key,lastBeat:val["lastBeat"], hr:val["hr"].toDouble(), hr2:val["hr2"].toDouble(), offline:!val["offline"], comment: "t1Rvs2AHV..", wallet:"");
         wdataList.add(record);
       });
       setState(() {
         data = wdataList;
       });
    }
  }
}