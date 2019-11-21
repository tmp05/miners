import 'package:flutter/material.dart';
import 'package:flutter_app/wallets.dart';
import 'package:flutter_app/Database.dart';
import 'constants.dart' as Constants;
import 'api.dart' as Api;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class walletslist extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return walletslistState();
  }
}

class walletslistState extends State<walletslist>{

  List<wallets> data = [];
  String _swipeDirection = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =  new GlobalKey<RefreshIndicatorState>();

  List <Widget> _buildList() {
    return data.map((wallets w)=>Dismissible(
      key:  ValueKey(w),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.endToStart){
          final bool res = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: const Text("Are you sure you wish to delete this wallet?"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      setState(() {
                        data.remove(w);
                        //добавить удаление кошелька!!!
                      });
                    },
                    child: const Text("DELETE")
                ),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                ),
              ],
            );
          },
        );}
      },
      background: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 30),
        alignment: AlignmentDirectional.centerStart,
      ),
      secondaryBackground: Container(
          color: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 30),
          alignment: AlignmentDirectional.centerEnd,
          //padding: EdgeInsets.symmetric(horizontal: 20),
          //alignment: AlignmentDirectional.centerStart,
          child: Icon(
            Icons.delete_forever,
      ),
      ),
      child: ListTile(
        title : Text(w.id.toString()),
        subtitle : Text( w.comment ?? ''),
        leading : CircleAvatar(
            backgroundColor: Colors.lightBlue,
            child:Text("ok")),
        trailing : Text("total "+w.count+", online="+w.online),
        onTap: () => onTapped(w),
        onLongPress: ()=>onLongPress(w),
      ),
    )).toList();
  }

  @override
  void initState(){
    super.initState();
    _refreshwallets();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Wallets:' +data.length.toString()+_swipeDirection),
          actions: <Widget>[
            InkWell(
            child: Icon(Icons.add),
            onTap: () {_addwallets(); },
          ),
          ],
      ),
      body: LiquidPullToRefresh(
          key: _refreshIndicatorKey,
          showChildOpacityTransition:true,
          onRefresh:_refreshwallets,
          child: ListView(
                children: _buildList(),
              )
      ),
    );
  }

  void onTapped(wallets w) async {
    Navigator.pushNamed(context, '/wlist',arguments: w);
   }

  void onLongPress(wallets w) async {
    dynamic  results = await Navigator.pushNamed(context, '/wallet',arguments: w);
    if (results!=null&&results.containsKey('update')) {
      _refreshwallets();
    }
  }
  _addwallets() async{
    dynamic  results = await Navigator.pushNamed(context, '/wallet', arguments: wallets(id:"",alias:Constants.alias,comment:"", online:"",count: ""));
    if (results!=null&&results.containsKey('update')) {
      _refreshwallets();
    }
  }

  Future<Null> _refreshwallets() async {
    await new Future.delayed(new Duration(seconds: 5));
    return Api.GetResponseForAll(data).then((_res){ DBProvider.db.getAllWallets().then((wWalletsList) =>
    {setState(() { data = wWalletsList;})});});

  }

}
