import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import '../../ble/ble_device_interactor.dart';

class CharacteristicInteractionDialog extends StatelessWidget {
  const CharacteristicInteractionDialog({
    required this.characteristic,
    Key? key,
  }) : super(key: key);
  final QualifiedCharacteristic characteristic;

  @override
  Widget build(BuildContext context) => Consumer<BleDeviceInteractor>(
      builder: (context, interactor, _) => _CharacteristicInteractionDialog(
            characteristic: characteristic,
            readCharacteristic: interactor.readCharacteristic,
            writeWithResponse: interactor.writeCharacterisiticWithResponse,
            writeWithoutResponse:
                interactor.writeCharacterisiticWithoutResponse,
            subscribeToCharacteristic: interactor.subScribeToCharacteristic,
          ));
}

class _CharacteristicInteractionDialog extends StatefulWidget {
  const _CharacteristicInteractionDialog({
    required this.characteristic,
    required this.readCharacteristic,
    required this.writeWithResponse,
    required this.writeWithoutResponse,
    required this.subscribeToCharacteristic,
    Key? key,
  }) : super(key: key);

  final QualifiedCharacteristic characteristic;
  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      readCharacteristic;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithResponse;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;

  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;

  @override
  _CharacteristicInteractionDialogState createState() =>
      _CharacteristicInteractionDialogState();
}

class _CharacteristicInteractionDialogState
    extends State<_CharacteristicInteractionDialog> {
  late String readOutput;
  late String writeOutput;
  late String subscribeOutput;
  late TextEditingController textEditingController;
  late StreamSubscription<List<int>>? subscribeStream;
  var visUp = true;
  var visDown = true;
  var visLeft = true;
  var visRight = true;
  List<int> tab = [3, 2, 4];
  var text = "stable";
  final time_MS = 800;
  List<int> bleTab = [];
  bool backToStable = true;
  bool isDifStable = true;
  bool startGame = true;

  @override
  void initState() {
    readOutput = '';
    writeOutput = '';
    subscribeOutput = '';
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    subscribeStream?.cancel();
    super.dispose();
  }

  List<int> enlargeSequence(List<int> list) {
    Random rng = Random();
    var r = 0;
    do {
      r = rng.nextInt(4);
    } while (r == 0);
    var list2 = list;
    list2.add(r);
    return list2;
  }

  bool compare(int a, int b) {
    return a == b;
  }

  Future<void> showRight() async {
    await Future.delayed(Duration(milliseconds: time_MS), () {
      setState(() {
        visDown = false;
        visRight = true;
        visUp = false;
        visLeft = false;
        text = "right";
      });
    });
  }

  Future<void> showDown() async {
    await Future.delayed(Duration(milliseconds: time_MS), () {
      setState(() {
        visDown = true;
        visRight = false;
        visUp = false;
        visLeft = false;
        text = "down";
      });
    });
  }

  Future<void> showLeft() async {
    await Future.delayed(Duration(milliseconds: time_MS), () {
      setState(() {
        visDown = false;
        visRight = false;
        visUp = false;
        visLeft = true;
        text = "left";
      });
    });
  }

  Future<void> showUp() async {
    await Future.delayed(Duration(milliseconds: time_MS), () {
      setState(() {
        visDown = false;
        visRight = false;
        visUp = true;
        visLeft = false;
        text = "up";
      });
    });
  }

  Future<void> showSequence() async {
    for (var element in tab) {
      switch (element) {
        case 0:
          await Future.delayed(Duration(milliseconds: time_MS), () {
            setState(() {
              visDown = true;
              visRight = true;
              visUp = true;
              visLeft = true;
              text = "stable";
            });
          });
          break;
        case 4:
          await Future.delayed(Duration(milliseconds: time_MS), () {
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
          await Future.delayed(Duration(milliseconds: time_MS), () {
            setState(() {
              visDown = false;
              visRight = false;
              visUp = false;
              visLeft = true;
              text = "left";
            });
          });

          break;
        case 1:
          await Future.delayed(Duration(milliseconds: time_MS), () {
            setState(() {
              visDown = false;
              visRight = false;
              visUp = true;
              visLeft = false;
              text = "up";
            });
          });

          break;
        case 3:
          await Future.delayed(Duration(milliseconds: time_MS), () {
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

  Future<void> showAll() async {
    await Future.delayed(Duration(milliseconds: time_MS), () {
      setState(() {
        visDown = true;
        visRight = true;
        visUp = true;
        visLeft = true;
      });
    });
  }

  Future<void> subscribeCharacteristic() async {
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
      setState(() {
        subscribeOutput = event.toString();
      });
    });
    setState(() {
      subscribeOutput = 'Notification set';
    });
  }

  int validate(int seqGesture, int userGesture, int index) {
    if (compare(seqGesture, userGesture)) {
      if (index == tab.length - 1) {
        return -200; // call enlargeSequence
      }
      return tab[index]; // is valid
    }
    return -1;
  }

  Future<void> readCharacteristic() async {
    while (true) {
      final result = await widget.readCharacteristic(widget.characteristic);
      var guest = result.toString();
      guest = guest[1];
      if (guest != "0" && backToStable) {
        setState(() {
          backToStable = false;
          bleTab.add(int.parse(guest));
        });
        print(guest);
        var i = bleTab.length - 1;
        var val = validate(tab[i], bleTab[i], i);
        if (val == -1) {
          setState(() {
            text = "you lost";
            startGame = true;
          });
          return;
        } else if (val == -200) {
          switch (val) {
            case 1:
              await showUp();
              break;
            case 2:
              await showLeft();
              break;
            case 3:
              await showDown();
              break;
            case 4:
              await showRight();
              break;
          }
          await showAll();
          setState(() {
            text = "level up";
            tab = enlargeSequence(tab);
            startGame = true;
          });
          return;
        } else {
          switch (val) {
            case 1:
              await showUp();
              break;
            case 2:
              await showLeft();
              break;
            case 3:
              await showDown();
              break;
            case 4:
              await showRight();
              break;
          }
          await showAll();
        }
      } else {
        if (guest == "0" && !backToStable) {
          setState(() {
            backToStable = true;
          });
        }
      }
      // setState(() {
      //   readOutput = result.toString();
      //   readOutput = readOutput[1];
      //   switch (readOutput) {
      //     case "0":
      //       visDown = true;
      //       visRight = true;
      //       visUp = true;
      //       visLeft = true;
      //       text = "stable";
      //       break;
      //     case "1":
      //       visDown = false;
      //       visRight = false;
      //       visUp = true;
      //       visLeft = false;
      //       text = "up";
      //       break;
      //     case "2":
      //       visDown = false;
      //       visRight = false;
      //       visUp = false;
      //       visLeft = true;
      //       text = "left";
      //       break;
      //     case "3":
      //       visDown = true;
      //       visRight = false;
      //       visUp = false;
      //       visLeft = false;
      //       text = "down";
      //       break;
      //     case "4":
      //       visDown = false;
      //       visRight = true;
      //       visUp = false;
      //       visLeft = false;
      //       text = "right";
      //       break;
      //   }
      // });
    }
  }

  List<int> _parseInput() => textEditingController.text
      .split(',')
      .map(
        int.parse,
      )
      .toList();

  Future<void> writeCharacteristicWithResponse() async {
    await widget.writeWithResponse(widget.characteristic, _parseInput());
    setState(() {
      writeOutput = 'Ok';
    });
  }

  Future<void> writeCharacteristicWithoutResponse() async {
    await widget.writeWithoutResponse(widget.characteristic, _parseInput());
    setState(() {
      writeOutput = 'Done';
    });
  }

  Widget sectionHeader(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );

  List<Widget> get readSection => [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Visibility(
              visible: startGame,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Background color
                ),
                onPressed: () async {
                  await subscribeCharacteristic();
                  setState(() {
                    startGame = false;
                  });
                  await showSequence();
                  setState(() {
                    text = "Go";
                  });
                  await readCharacteristic();
                },
                child: const Text('Start Game'),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              text,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.red, fontSize: 30),
            ),
            const SizedBox(
              height: 20,
            ),
            Visibility(
              visible: visUp,
              child: const Icon(
                Icons.arrow_circle_up,
                color: Colors.green,
                size: 100.0,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                  visible: visLeft,
                  child: const Icon(
                    Icons.arrow_circle_left,
                    color: Colors.red,
                    size: 100.0,
                  ),
                ),
                const SizedBox(
                  width: 60,
                ),
                Visibility(
                  visible: visRight,
                  child: const Icon(
                    Icons.arrow_circle_right,
                    color: Colors.yellow,
                    size: 100.0,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Visibility(
              visible: visDown,
              child: const Icon(
                Icons.arrow_circle_down,
                color: Colors.blue,
                size: 100.0,
              ),
            ),
          ],
        ),
      ];

  List<Widget> get subscribeSection => [
        sectionHeader('Subscribe / notify'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: subscribeCharacteristic,
              child: const Text('Subscribe'),
            ),
            Text('Output: $subscribeOutput'),
          ],
        ),
      ];

  Widget get divider => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Divider(thickness: 2.0),
      );

  @override
  Widget build(BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              divider,
              ...readSection,
              divider,
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('close')),
                ),
              )
            ],
          ),
        ),
      );
}
