import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/database.dart';
import 'package:flutter_app/statistics.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:postgres/postgres.dart';
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
  TextEditingController messageController = TextEditingController();
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
          RaisedButton(
            onPressed: positiveTest,
            child: new Text(
                "Positive test",
                style: TextStyle(fontSize: 20)
            ),
          ),
          const SizedBox(height: 30),
          RaisedButton(
            onPressed: negativeTest,
            child: new Text(
                "Negative test",
                style: TextStyle(fontSize: 20)
            ),
          ),
          const SizedBox(height: 30),
          RaisedButton(
            onPressed: noTest,
            child: new Text(
                "No test",
                style: TextStyle(fontSize: 20)
            ),
          ),
          TextField(
            controller: messageController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Bluetooth MAC',
            ),
          )
        ],
      ),
    );
  }

  void positiveTest(){
    DeviceWithAppDatabaseProvider.db.addDeviceToDatabase(new DeviceWithApp(DateTime.now().toIso8601String().toString(),messageController.text, "positive test"));
    synchronizeDBs();
  }
  void negativeTest(){
    DeviceWithAppDatabaseProvider.db.addDeviceToDatabase(new DeviceWithApp(DateTime.now().toIso8601String().toString(),messageController.text, "negative test"));
    synchronizeDBs();
  }
  void noTest(){
    DeviceWithAppDatabaseProvider.db.addDeviceToDatabase(new DeviceWithApp(DateTime.now().toIso8601String().toString(),messageController.text, "not tested"));
    synchronizeDBs();
  }



  void scanButton(){

    setState(() {

      if(widget.scanning){
        stopScan();
        widget.scanning = false;
      }
      else{
        scan().then((succes)  {
          if(succes){
            setState(() {
              widget.scanning = true;
            });

          }
          else{
            Fluttertoast.showToast(
                msg: "Bluetooth needs to be enabled and permissions need to be granted",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );

          }
        });
      }
    });
    }

}
StreamSubscription scanSubscription;

void stopScan(){
  scanSubscription.cancel();
  flutterBlue.stopScan();
}

Future<bool> scan() async {
  var status = await Permission.location.status;

  print(status);
  if(! await flutterBlue.isAvailable || ! await flutterBlue.isOn || ! await Permission.location.request().isGranted){
    return false;
  }
  try{
    scanSubscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
        print(r.device.id.toString());
        FoundDeviceDatabaseProvider.db.addFoundDeviceToDatabase(new FoundDevice(DateTime.now().toIso8601String().toString(), r.device.id.toString()));
      }
    });
    flutterBlue.startScan();
  } catch (e){
    stopScan();
    return false;
  }

  return true;
}

Future<void> synchronizeDBs() async {
  var connection = new PostgreSQLConnection("welsch.pro", 2943, "corona", username: "dart", password: "21370huijs01");
  await connection.open();
  //TABLES have to exist!!!!!!!!!1
  /*
  CREATE TABLE devices (time TEXT PRIMARY KEY, mac TEXT, status TEXT);
   */
  List<DeviceWithApp> localEntries = await DeviceWithAppDatabaseProvider.db.getAllDevicesWithApp();
  List<List<dynamic>> devices = await connection.query("SELECT * FROM devices");
  List<DeviceWithApp> serverEntries = new List();
  for(final row in devices){
    serverEntries.add(new DeviceWithApp(row[0], row[1], row[2]));
  }
  for(DeviceWithApp device in localEntries){
    if(!serverEntries.contains(device))
      await connection.query("INSERT INTO devices (time, mac, status) VALUES ('"+device.time+"','"+device.mac+"','"+device.status+"') ON CONFLICT DO NOTHING");
  }
  for(DeviceWithApp device in serverEntries){
    if(!localEntries.contains(device))
      localEntries.add(device);
  }


}
