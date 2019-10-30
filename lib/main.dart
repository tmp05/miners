import 'package:flutter/material.dart';
import 'package:flutter_app/detailswallet.dart';
import 'package:flutter_app/wallets.dart';
import 'package:flutter_app/walletslist.dart';
import 'package:flutter_app/workersdata.dart';
import 'package:flutter_app/workerslist.dart';
import 'package:flutter_app/details.dart';

class MineTracker extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) => makeRoute(
              context: context,
              routeName: settings.name,
              arguments: settings.arguments,
            ),
            maintainState: true,
            fullscreenDialog: false,
          );
        },
      title:'MyMine',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: walletslist()
    );

  }

  Widget makeRoute(
      {@required BuildContext context,
        @required String routeName,
        Object arguments}) {
    final Widget child =
    _buildRoute(context: context, routeName: routeName, arguments: arguments);
    return child;
  }

  Widget _buildRoute({
    @required BuildContext context,
    @required String routeName,
    Object arguments,
  }) {
    switch (routeName) {
      case '/wlist': //workers
        return workerslist();
      case '/wallets': // wallets
        return walletslist();
      case '/worker': // one worker
        workersdata w = arguments as workersdata;
        return WorkerView(w:w);
      case '/wallet': // one wallet
        wallets w = arguments as wallets;
        return WalletView(w:w);
      default:
        throw 'Route $routeName is not defined';
    }
  }
}


void main() => runApp(MineTracker());
