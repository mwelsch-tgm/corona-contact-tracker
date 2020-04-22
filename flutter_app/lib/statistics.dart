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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder<List<FoundDevice>>(
      future: FoundDeviceDatabaseProvider.db.getAllFoundDevices(),
      builder: (BuildContext context, AsyncSnapshot<List<FoundDevice>> snapshot) {
        if (snapshot.hasData){
          String s = "Total Database entries: "+snapshot.data.length.toString();
          s += ;
          return Center(child: Text(s));
        }
        else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}