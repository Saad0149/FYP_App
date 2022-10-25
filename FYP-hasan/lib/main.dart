import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

bool shouldUseFirestoreEmulator = false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CollectionReference _ble_id =
      FirebaseFirestore.instance.collection('ble_id');

  Future<void> perm() async {
    await Permission.locationAlways.request();
    await Permission.sensors.request();
    await Permission.accessNotificationPolicy.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothAdvertise.request();
    await Permission.bluetoothConnect.request();
    // await Permission.storage.request();
  }

  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> scanResultList = [];
  bool isScanning = false;
  var scan_mode = 0;
  var ble_macs = ["08:3A:F2:B7:D7:16"];
  var detected_bles = [];

  void scan() async {
    flutterBlue.scanResults.listen((results) {
      // do something with scan results

      scanResultList = results;

      for (int j = 0; j < ble_macs.length; j++) {
        for (int i = 0; i < scanResultList.length; i++) {
          if (scanResultList[i].device.id.toString() == ble_macs[j]) {
            print("send advertisement");
            detected_bles.add(scanResultList[i]);
            // ble_macs.remove(ble_macs[j]);
          }
        }
      }
      if (detected_bles.isNotEmpty) {
        for (int i = 0; i < detected_bles.length; i++) {}
      }
    });
  }

  void toggleState() {
    isScanning = !isScanning;

    if (isScanning) {
      flutterBlue.startScan(
          scanMode: ScanMode(scan_mode), allowDuplicates: true);
      scan();
    } else {
      flutterBlue.stopScan();
    }
    setState(() {});
  }

  _MyHomePageState() {
    perm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(child: Text('No Advertisement to show')),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleState,
        child: Icon(isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}
