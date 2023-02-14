import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';


class Simon extends StatefulWidget {
  const Simon({Key? key}) : super(key: key);

  @override
  State<Simon> createState() => _SimonState();
}

class _SimonState extends State<Simon> {
  var visUp = true;
  var visDown = true;
  var visLeft = true;
  var visRight = true;
  List<int> tab = [0, 1, 2, 3, 4];
  var text = "stable";
  late Stream<List<int>> _characteristicValueStream;

  var _value;

  void _connectToBLE() async {
    FlutterBlue.instance.state.listen((state) async {
      if (state == BluetoothDeviceState.connected) {
        final connectedDevices = await FlutterBlue.instance.connectedDevices;
        if (connectedDevices.isNotEmpty) {
          final device = connectedDevices.first;
          final services = await device.discoverServices();
          if (services.isNotEmpty) {
            final service = services.first;
            final characteristics = await service.characteristics;
            if (characteristics.isNotEmpty) {
              final characteristic = characteristics.first;
              _characteristicValueStream = characteristic.value;
              _characteristicValueStream.listen((data) {
                if (data.length > 0) {
                  _value = String.fromCharCode(data[0]);
                }
              });
            }
          }
        }
      }
    });
  }

  void setVisibility() {}

  List<int> enlargeSequence(List<int> list) {
    Random rng = Random();
    int num = rng.nextInt(4);
    var list2 = list;
    list2.add(num);
    return list2;
  }

  // 0 -> stable
  // 1 -> right
  // 2 -> left
  // 3 -< up
  // 4 -> down

  Future<void> showSequence() async {
    for (var element in tab) {
      print(element);
      switch (element) {
        case 0:
          print("here");
          await Future.delayed(Duration(seconds: 1), () {
            setState(() {
              visDown = true;
              visRight = true;
              visUp = true;
              visLeft = true;
              text = "stable";
            });
          });
          break;
        case 1:
          await Future.delayed(Duration(seconds: 1), () {
            setState(() {
              visDown = false;
              visRight = true;
              visUp = false;
              visLeft = false;
              text = "right";
            });
          });

          break;
        case 2:
          await Future.delayed(Duration(seconds: 1), () {
            setState(() {
              visDown = false;
              visRight = false;
              visUp = false;
              visLeft = true;
              text = "left";
            });
          });

          break;
        case 3:
          await Future.delayed(Duration(seconds: 1), () {
            setState(() {
              visDown = false;
              visRight = false;
              visUp = true;
              visLeft = false;
              text = "up";
            });
          });

          break;
        case 4:
          await Future.delayed(Duration(seconds: 1), () {
            setState(() {
              visDown = true;
              visRight = false;
              visUp = false;
              visLeft = false;
              text = "down";
            });
          });
      }
      await showAll();
    }
    setState(() {
      text = "Start";
    });
  }

  @override
  Widget build(BuildContext context) {
    _connectToBLE();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Simon'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Background color
            ),
            onPressed: () async {
              await showSequence();
            },
            child: const Text("Start Game"),
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 40
            ),
          ),
          SizedBox(height: 20,),
          Container(
            child: Visibility(
              visible: visUp,
              child: Icon(
                Icons.arrow_circle_up,
                color: Colors.green,
                size: 150.0,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Visibility(
                  visible: visLeft,
                  child: const Icon(
                    Icons.arrow_circle_left,
                    color: Colors.red,
                    size: 150.0,
                  ),
                ),
              ),
              const SizedBox(
                width: 60,
              ),
              Container(
                child: Visibility(
                  visible: visRight,
                  child: Icon(
                    Icons.arrow_circle_right,
                    color: Colors.yellow,
                    size: 150.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            child: Visibility(
              visible: visDown,
              child: Icon(
                Icons.arrow_circle_down,
                color: Colors.blue,
                size: 150.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showAll() async {
    await Future.delayed(Duration(seconds: 1), () {
      setState(() {
        visDown = true;
        visRight = true;
        visUp = true;
        visLeft = true;
      });
    });
  }
}
