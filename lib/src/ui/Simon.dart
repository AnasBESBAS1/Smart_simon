import 'dart:math';

import 'package:flutter/material.dart';

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

  bool compare(int a, int b) {
    return a == b;
  }

  bool backToStable(gus){
    return gus != "0";
  }

  List<int> enlargeSequence(List<int> list) {
    Random rng = Random();
    int num = rng.nextInt(4);
    var list2 = list;
    list2.add(num);
    return list2;
  }

  int validate(int seqGesture, int userGesture, int index){
    if (compare(seqGesture, userGesture)){
      if (index == tab.length-1){
        return -200; // call enlargeSequence
      }
      return tab[index]; // is valid
    }
    return -1;
  }

  void decision(int liveData){

  }

  // 0 -> stable
  // 1 -> right
  // 2 -> left
  // 3 -< up
  // 4 -> down

  Future<void> showSequence() async {
    for (var element in tab) {
      switch (element) {
        case 0:
          await Future.delayed(const Duration(seconds: 1), () {
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
          await Future.delayed(const Duration(seconds: 1), () {
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
          await Future.delayed(const Duration(seconds: 1), () {
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
          await Future.delayed(const Duration(seconds: 1), () {
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
          await Future.delayed(const Duration(seconds: 1), () {
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
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.red, fontSize: 40),
          ),
          SizedBox(
            height: 20,
          ),
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
