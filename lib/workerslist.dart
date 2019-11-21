import 'package:flutter/material.dart';
import 'package:flutter_app/workersdata.dart';
import 'package:flutter_app/wallets.dart';
import 'package:flutter_app/Database.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

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

  List<workersdata> data = [];

  var timezoneOffset = new DateTime.now().timeZoneOffset;

  List <Widget> _buildList() {
    return data.map((workersdata w)=>ListTile(
      title : Text(w.id_worker),
      subtitle : Text(DateTime.fromMillisecondsSinceEpoch(w.date*1000).toString()),
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
    _refreshworkers();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_w.comment+"("+data.length.toString()+")"),
        ),
        body: LiquidPullToRefresh(
            key: _refreshIndicatorKey,
            showChildOpacityTransition:true,
            onRefresh:_refreshworkers,
            child: ListView(
              children: _buildList(),

            )
        ),
    );
  }

  void onTapped(workersdata w) {
    Navigator.pushNamed(context, '/worker', arguments: w);
  }

    Future<Null> _refreshworkers() async {
    await new Future.delayed(new Duration(seconds: 5));
    await DBProvider.db.getAllWalletClients(_w).then((wDatabaseList)=>{
      setState(() {
        data = wDatabaseList;
      })
    });

  }

}