import 'package:flutter/material.dart';
import 'package:flutter_app/database.dart';

import 'main.dart';

class StatisticsWidget extends StatefulWidget {
  static const String id = "STATISTICS";
  @override
  _StatisticsState createState() => _StatisticsState();


}

class _StatisticsState extends State<StatisticsWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      appBar: AppBar(title: Text("Corona Statistics")),
      body: StatisticsBody(),
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

class StatisticsBody extends StatefulWidget{
  @override
  _StatisticsBodyState createState() => _StatisticsBodyState();
}


class _StatisticsBodyState extends State<StatisticsBody>{
  Future<List<FoundDevice>> foundDevices;
  List<DeviceWithApp> devicesWithApp;

  ScrollController scrollController = new ScrollController();

  Future<List<FoundDevice>> initFutures() async {
    devicesWithApp = await DeviceWithAppDatabaseProvider.db.getAllDevicesWithApp();
    return FoundDeviceDatabaseProvider.db.getAllFoundDevices();
  }

  @override
  void initState(){
    super.initState();
    foundDevices = initFutures();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder<List<FoundDevice>>(
      future: foundDevices,
      builder: (BuildContext context, AsyncSnapshot<List<FoundDevice>> snapshot) {
        if (snapshot.hasData){
          List<Widget> entries = new List();
          entries.add(new Text("Total Database entries: "+snapshot.data.length.toString()));
          for(FoundDevice foundDevice in snapshot.data){
            for(DeviceWithApp deviceWithApp in devicesWithApp){
              print("?"+deviceWithApp.mac);
              print(foundDevice.mac);
              if(deviceWithApp.mac == foundDevice.mac){
                entries.add(new Text("MAC Match! Contact date: "+foundDevice.time + " Entrie time of status: " + deviceWithApp.time + " Status: " + deviceWithApp.status));
              }
            }
          }

          //s += ;
          return ListView(
            controller: scrollController,
          children: <Widget>[
            ...entries,
          ],
          );
        }
        else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}