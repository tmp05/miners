import 'package:flutter/material.dart';
import 'package:flutter_app/constants.dart';
import 'package:flutter_app/wallets.dart';
import 'api.dart' as Api;
import 'Database.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

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
  List<String> _servers = [];
  final _formKey = GlobalKey<FormState>();

  // manage state of modal progress HUD widget
  bool _isInAsyncCall = false;
  bool _isInvalidAsyncId = false; // managed after response from server

  // validate id
  String _validateId(String Id) {
    if (Id=='') {return 'Id is empty';}

    if (_isInvalidAsyncId) {
      // disable message until after next async call
      setState(() {_isInvalidAsyncId = false;});
      return 'Incorrect Id for this Wallet';
    }
    return null;
  }


  WalletViewState({@required wallets w}) : _w = w;

  Widget _buildWidget() {
    _formKey.currentState?.validate();
    return new SafeArea(
      top: true,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            TextFormField(
              key: Key('id'),
              validator:  _validateId,
              decoration: new InputDecoration(labelText: "Id"),
              initialValue:_w.id,
              onChanged: (newval){
                setState(() {widget.w.id = newval;});
              },
            ),
            new FormField(
              builder: (FormFieldState state) {
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Alias',
                  ),
                  isEmpty: widget.w.alias == '',
                  child: new DropdownButtonHideUnderline(
                    child: new DropdownButton(
                      value: widget.w.alias,
                      isDense: true,
                      onChanged: (String newValue) {
                        setState(() {
                          widget.w.alias= newValue;
                        });
                      },
                      items: _servers.map((String value) {
                        return new DropdownMenuItem(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            TextFormField(
              decoration: new InputDecoration(labelText: "Comment"),
              initialValue:_w.comment,
              onChanged: (newval){
                setState(() {widget.w.comment = newval;});
              },
            ),
            new RaisedButton(
                onPressed: _submit,
                child: Text(
                    'Save',
                    style: TextStyle(fontSize: 15)
                )),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( _w.id ?? 'New wallet'),
        backgroundColor: Colors.lightBlue,
      ),
      body: ModalProgressHUD(
        child: _buildWidget(),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),),
    );
  }

  void _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      // dismiss keyboard during async call
      FocusScope.of(context).requestFocus(new FocusNode());

      // start the modal progress HUD
      setState(() {
        _isInAsyncCall = true;
      });

      Api.GetResponse(_w.alias, _w.id ?? '').then((res) {
        setState(() {
          if (res) {
            _isInvalidAsyncId = false;
          }
          else {
            _isInvalidAsyncId = true;
          }
        });
        if (!_isInvalidAsyncId) {_saveState();}
        else { setState(() {_isInAsyncCall = false; });}
      });
    }
  }

  @override
  void initState(){
      super.initState();
      _getservers();
  }


  Future<dynamic> _getservers() async {
    setState(() { _isInAsyncCall = true; });
    return Api.GetServers().then((_res){
      setState(() {
        _servers = _res;
        _isInAsyncCall = false;
      });
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
                // stop the modal progress HUD
                _isInAsyncCall = false;
                Navigator.pop(context, {'update': true});
              })
            });
          }
      }
  }
}

