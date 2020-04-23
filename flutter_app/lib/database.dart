import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FoundDevice{
  final String time;
  final String mac;

  FoundDevice(this.time, this.mac);

  factory FoundDevice.fromMap(Map<String, dynamic> json) => new FoundDevice(
    json["time"],
    json["mac"],
  );

  Map<String, dynamic> toMap() {
    return {
      'time' : time,
      'mac' : mac,
    };
  }

}

class FoundDeviceDatabaseProvider {
  FoundDeviceDatabaseProvider._();

  static final FoundDeviceDatabaseProvider db = FoundDeviceDatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await getDatabaseInstance();
    return _database;
  }

  Future<Database> getDatabaseInstance() async {
    String path = join(await getDatabasesPath(), "corona.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE FoundDevice ("
              "time TEXT PRIMARY KEY,"
              "mac TEXT"
              ")");
        });
  }

  addFoundDeviceToDatabase(FoundDevice device) async {
    final db = await database;
    var raw = await db.insert(
      "FoundDevice",
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }



  Future<List<FoundDevice>> getAllFoundDevices() async {
    final db = await database;
    var response = await db.query("FoundDevice");
    List<FoundDevice> list = response.map((c) => FoundDevice.fromMap(c)).toList();
    return list;
  }


  deleteAllFoundDevice() async {
    final db = await database;
    db.delete("FoundDevice");
  }
}
class DeviceWithApp{
  final String mac;
  final String time;
  final String status;

  DeviceWithApp(this.time, this.mac, this.status);

  factory DeviceWithApp.fromMap(Map<String, dynamic> json) => new DeviceWithApp(
    json["time"],
    json["mac"],
    json["status"],
  );

  Map<String, dynamic> toMap() {
    return {
      'time' : time,
      'mac' : mac,
      'status' : status,
    };
  }

}


class DeviceWithAppDatabaseProvider {
  DeviceWithAppDatabaseProvider._();

  static final DeviceWithAppDatabaseProvider db = DeviceWithAppDatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await getDatabaseInstance();
    return _database;
  }

  Future<Database> getDatabaseInstance() async {
    String path = join(await getDatabasesPath(), "devices.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE DeviceWithApp ("
              "time TEXT PRIMARY KEY,"
              "mac TEXT,"
              "status TEXT"
              ")");
        });
  }

  addDeviceToDatabase(DeviceWithApp device) async {
    final db = await database;
    var raw = await db.insert(
      "DeviceWithApp",
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }



  Future<List<DeviceWithApp>> getAllDevicesWithApp() async {
    final db = await database;
    var response = await db.query("DeviceWithApp");
    List<DeviceWithApp> list = response.map((c) => DeviceWithApp.fromMap(c)).toList();
    return list;
  }


  deleteAllFoundDevice() async {
    final db = await database;
    db.delete("DeviceWithApp");
  }
}