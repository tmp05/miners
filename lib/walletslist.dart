import 'package:flutter/material.dart';
import 'package:flutter_app/wallets.dart';
import 'package:flutter_app/wallets.dart';
import 'package:flutter_app/workersinfo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/Database.dart';
import 'constants.dart' as Constants;

class walletslist extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return walletslistState();
  }
}

class walletslistState extends State<walletslist>{

  List<wallets> data = [];


  List <Widget> _buildList() {
    return data.map((wallets w)=>ListTile(
      title : Text(w.id.toString()),
      subtitle : Text(w.comment),
      leading : CircleAvatar(
          backgroundColor: Colors.lightBlue,
          child:Text("ok")),
      onTap: () => onTapped(w),
    )).toList();
  }

  @override
  void initState(){
    super.initState();
    _loadwallets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallets:' +data.length.toString()),
      ),
      body: Container(
          child: ListView(
            children: _buildList(),
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: ()=>{_addwallets(), _loadwallets()}
      ),
    );
  }

  void onTapped(wallets w) async {
    dynamic  results = await Navigator.pushNamed(context, '/wallet', arguments: w);
    if (results!=null&&results.containsKey('update')) {
      _loadwallets();
    }
  }

  _addwallets() async{
    dynamic  results = await Navigator.pushNamed(context, '/wallet', arguments: wallets(id:"",alias:Constants.alias,comment:""));
    if (results!=null&&results.containsKey('update')) {
      _loadwallets();
    }
  }

   _loadwallets() async {
     await DBProvider.db.getAllWallets().then((wWalletsList)=>{
       setState(() {
         data = wWalletsList;
       })
     });
  }

}