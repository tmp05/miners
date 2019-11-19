import 'package:flutter/material.dart';
import 'package:flutter_app/wallets.dart';
import 'api.dart' as Api;
import 'Database.dart';


class WalletView extends StatefulWidget{
  wallets w;
  WalletView({Key key, this.w}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WalletViewState(w: this.w);
  }
}

class WalletViewState extends State<WalletView>{
  wallets _w;
  final _formKey = GlobalKey<FormState>();

  WalletViewState({@required wallets w}) : _w = w;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( _w.id ?? 'New wallet'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SafeArea(
        top: true,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                validator: (value)  => _check(widget.w),
                decoration: new InputDecoration(labelText: "Id"),
                initialValue:_w.id,
                onChanged: (newval){
                  setState(() {widget.w.id = newval;});
                },
              ),
              TextFormField(
                validator: (value){
                  if (value.isEmpty) return 'Alias is empty';
                },
                decoration: new InputDecoration(labelText: "Alias"),
                initialValue:_w.alias,
                onChanged: (newval){
                  setState(() {widget.w.alias = newval;});
                },
              ),
              TextFormField(
                decoration: new InputDecoration(labelText: "Comment"),
                initialValue:_w.comment,
                onChanged: (newval){
                  setState(() {widget.w.comment = newval;});
                },
              ),
              new RaisedButton(onPressed: (){
                _saveState();
              },
                  child: Text(
                      'Cохранить',
                      style: TextStyle(fontSize: 15)
                  )),

            ],
          ),
        ),
      ),
    );
  }

  _check  (wallets w) {
    if (w.id=='') {return 'Id is empty';}
    Api.GetResponse(w.alias, w.id ?? '').then((res) {
      if (res!=null) {return null;}
      else {return 'Wrong Id for the Alias';}
    });
  }
  _saveState() async{
    if(_formKey.currentState.validate()) {
          dynamic result = await DBProvider.db.newWallet(widget.w);
          if (result!=null) {
            await DBProvider.db.getOnlineAndCount(widget.w).then((
                wDatabaseList) =>
            {
              setState(() {
                widget.w.online = wDatabaseList[0].online.toString();
                widget.w.count = wDatabaseList[0].count.toString();
              })
            });
            Navigator.pop(context, {'update': true});
          }
      }
  }
}

