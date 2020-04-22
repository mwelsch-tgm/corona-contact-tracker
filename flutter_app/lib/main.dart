import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/database.dart';
import 'package:flutter_app/statistics.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';



final  FlutterBlue flutterBlue = FlutterBlue.instance;

void main() async{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final appTitle = 'My Data';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: appTitle,
        home: MyHomePage(title: appTitle),
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        initialRoute: MyHomePage.id,
        routes: {
          MyHomePage.id: (context) => MyHomePage(title: appTitle),
          StatisticsWidget.id: (context) => StatisticsWidget(),
        },

    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  static const String id = "HOMESCREEN";
  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //scan();
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: MyDataBody(),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Statistics'),
              onTap: () {
                // Update the state of the app

                // Then close the drawer
                Navigator.pop(context);
                Navigator.of(context).pushNamed(StatisticsWidget.id);

              },
            ),
            ListTile(
              title: Text('My Data'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.of(context).pushNamed(MyHomePage.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyDataBody extends StatefulWidget{
  bool scanning = false;
  @override
  _MyDataState createState() => _MyDataState();
}

class _MyDataState extends State<MyDataBody>{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 30),
          RaisedButton(
            onPressed: scanButton,
            child: new Text(
                widget.scanning ? 'Disable Background Scan' : 'Enabled Background Scan',
                style: TextStyle(fontSize: 20)
            ),
          ),
          const SizedBox(height: 30),

        ],
      ),
    );
  }

  void scanButton(){
    setState(() {
      if(widget.scanning){
        stopScan();
        widget.scanning = false;
      }
      else{
        scan();
        widget.scanning = true;
      }
    });
    }

}
StreamSubscription scanSubscription;

void stopScan(){
  scanSubscription.cancel();
  flutterBlue.stopScan();
}

Future<void> scan() async {
  var status = await Permission.location.status;

  FoundDeviceDatabaseProvider.db.getDatabaseInstance();

  print(await Permission.location.request().isGranted);
  print(status);
  scanSubscription = flutterBlue.scanResults.listen((results) {
    // do something with scan results
    for (ScanResult r in results) {
      print('${r.device.name} found! rssi: ${r.rssi}');
      print(r.device.id.toString());
      FoundDeviceDatabaseProvider.db.addFoundDeviceToDatabase(new FoundDevice(DateTime.now().toIso8601String().toString(), r.device.id.toString()));
    }
  });
  flutterBlue.startScan();
}


