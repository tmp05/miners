import 'package:flutter/material.dart';
import 'package:flutter_app/wallets.dart';
import 'package:flutter_app/Database.dart';
import 'constants.dart' as Constants;
import 'api.dart' as Api;

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
      trailing : Text("total "+w.count+", online="+w.online),
      onTap: () => onTapped(w),
      onLongPress: ()=>onLongPress(w),
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
          actions: <Widget>[
            InkWell(
            child: Icon(Icons.add),
            onTap: () {_addwallets(); },
          ),
          ],
      ),
      body: Container(
          child: ListView(
            children: _buildList(),
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: ()=>_loadwallets()
      ),
    );
  }

  void onTapped(wallets w) async {
    Navigator.pushNamed(context, '/wlist',arguments: w);
   }

  void onLongPress(wallets w) async {
    dynamic  results = await Navigator.pushNamed(context, '/wallet',arguments: w);
    if (results!=null&&results.containsKey('update')) {
      _loadwallets();
    }
  }
  _addwallets() async{
    dynamic  results = await Navigator.pushNamed(context, '/wallet', arguments: wallets(id:"",alias:Constants.alias,comment:"", online:"",count: ""));
    if (results!=null&&results.containsKey('update')) {
      _loadwallets();
    }
  }

   void _loadwallets() async {
    bool res = await Api.GetResponseForAll(data);
    if (res) {
      await DBProvider.db.getAllWallets().then((wWalletsList) =>
      {
        setState(() {
          data = wWalletsList;
        })
      });
    }
  }

}