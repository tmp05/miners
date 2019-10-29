import 'package:flutter/material.dart';
import 'package:flutter_app/workersdata.dart';

import 'Database.dart';


class WorkerView extends StatefulWidget{
  workersdata w;
  WorkerView({Key key, this.w}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WorkerViewState(w: this.w);
  }
}

class WorkerViewState extends State<WorkerView>{
  workersdata _w;
  String _comment;

  WorkerViewState({@required workersdata w}) : _w = w;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_w.id_worker.toString()),
        backgroundColor: ((_w.offline==false)?Colors.lightBlue:Colors.red),
      ),
      body: SafeArea(
        top: true,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("info time: "+DateTime.fromMillisecondsSinceEpoch(_w.date+7*60*60*1000).toLocal().toString(),style:TextStyle(fontWeight: FontWeight.bold, fontSize: 18, height: 2)),
              Text("hashCode "+_w.hashCode.toString(),style:TextStyle(fontWeight: FontWeight.bold, fontSize: 18, height: 2)),
              Text("hr "+_w.hr.toString(),style:TextStyle(fontWeight: FontWeight.bold, fontSize: 18, height: 2)),
              Text("hr2  "+_w.hr2.toString(),style:TextStyle(fontWeight: FontWeight.bold, fontSize: 18, height: 2)),
              Text("device is"+((_w.offline==false)?" online":" offline"),style:TextStyle(fontWeight: FontWeight.bold, fontSize: 18, height: 2)),
              TextFormField(
                decoration: new InputDecoration(labelText: "Comment"),
                initialValue:_w.comment,
                  onChanged: (newval){
                    _comment = newval;
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

  _saveState()  {
    setState(() {
      widget.w.comment = _comment;
      DBProvider.db.updateWorker(widget.w.id_worker, _comment);
    });
    Navigator.pop(context);
  }
}

