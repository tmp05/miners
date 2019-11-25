import 'package:flutter/material.dart';
import 'package:flutter_app/workersdata.dart';
import 'package:flutter_app/wallets.dart';
import 'package:flutter_app/Database.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'api.dart' as Api;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class workerslist extends StatefulWidget{
  wallets w;
  workerslist({Key key, this.w}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
     return workerslistState(w: this.w);
  }
}

class workerslistState extends State<workerslist>{
  wallets _w;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =  new GlobalKey<RefreshIndicatorState>();
  workerslistState({@required wallets w}) : _w = w;
  bool _loading = false;

  List<workersdata> data = [];

  List <Widget> _buildList() {
    return data.map((workersdata w)=>ListTile(
      title : Text(w.id_worker),
      subtitle : Text(DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(w.date*1000))),
      leading : CircleAvatar(
          backgroundColor: (w.offline==false?Colors.lightBlue:Colors.red),
          child:Text((w.offline==false?"ok":"!"))),
      trailing : Text("hr="+w.hr.toString()+",hr2="+w.hr2.toString()),
      onTap: () => onTapped(w),
    )).toList();
  }

  @override
  void initState(){
    super.initState();
    setState(() {
      _loading = true;
    });
    _refreshworkers();
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_w.comment+"("+data.length.toString()+")"),
      ),
      body: ModalProgressHUD(
          child:  LiquidPullToRefresh(
              key: _refreshIndicatorKey,
              showChildOpacityTransition:true,
              onRefresh:_refreshworkers,
              child: ListView(
                children: _buildList(),
              )
          ),
          inAsyncCall: _loading),
    );
  }



  void onTapped(workersdata w) {
    Navigator.pushNamed(context, '/worker', arguments: w);
  }

  Future<dynamic> _refreshworkers() async {
     return Api.GetResponse(_w.alias,_w.id).then((_res){ DBProvider.db.getAllWalletClients(_w).then((wDatabaseList) =>
      {setState(() { data = wDatabaseList; _loading = false;})});});

  }

}