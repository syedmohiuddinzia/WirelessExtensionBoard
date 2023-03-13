import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:led/pinout.dart';
import 'package:web_socket_channel/io.dart';

enum SingingCharacter {
  digital,
  analog,
}

enum SingingCharacter2 {
  off,
  slow,
  moderate,
  fast,
  on,
}

//apply this class on home: attribute at MaterialApp()
class WebSocketLed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebSocketLed();
  }
}

class _WebSocketLed extends State<WebSocketLed> {
  SingingCharacter? _character = SingingCharacter.digital;
  SingingCharacter2? _level = SingingCharacter2.off;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  late bool D0status; //boolean value to track LED status, if its ON or OFF
  late bool D1status;
  late bool D2status;
  late bool D3status;
  late bool D4status;
  late bool D5status;
  late bool D6status;
  late bool D7status;

  late bool D2modeA = false;
  late String D2level = "";

  late bool D5modeA = false;
  late String D5level = "";

  late bool D6modeA = false;
  late String D6level = "";

  late IOWebSocketChannel channel;
  late bool connected; //boolean value to track if WebSocket is connected
  bool d0 = false;
  final D0Controller = TextEditingController();
  final D1Controller = TextEditingController();
  final D2Controller = TextEditingController();
  final D3Controller = TextEditingController();
  final D4Controller = TextEditingController();
  final D5Controller = TextEditingController();
  final D6Controller = TextEditingController();
  final D7Controller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    D0Controller.dispose();
    D1Controller.dispose();
    D2Controller.dispose();
    D3Controller.dispose();
    D4Controller.dispose();
    D5Controller.dispose();
    D6Controller.dispose();
    D7Controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    D0status = false; //initially leadstatus is off so its FALSE
    D1status = false;
    D2status = false;
    D3status = false;
    D4status = false;
    D5status = false;
    D6status = false;
    D7status = false;

    connected = false; //initially connection status is "NO" so its FALSE

    if (D0Controller.text == "") {
      D0Controller.text = "D0";
    }

    if (D1Controller.text == "") {
      D1Controller.text = "D1";
    }

    if (D2Controller.text == "") {
      D2Controller.text = "D2";
    }

    if (D3Controller.text == "") {
      D3Controller.text = "D3";
    }

    if (D4Controller.text == "") {
      D4Controller.text = "D4";
    }

    if (D5Controller.text == "") {
      D5Controller.text = "D5";
    }

    if (D6Controller.text == "") {
      D6Controller.text = "D6";
    }

    if (D7Controller.text == "") {
      D7Controller.text = "D7";
    }
    Future.delayed(Duration.zero, () async {
      channelconnect(); //connect to WebSocket wth NodeMCU
    });

    super.initState();
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => pinout(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.fastOutSlowIn;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  channelconnect() {
    //function to connect
    try {
      channel =
          IOWebSocketChannel.connect("ws://192.168.0.1:81"); //channel IP : Port
      channel.stream.listen(
        (message) {
          print(message);
          setState(() {
            if (message == "connected") {
              connected = true; //message is "connected" from NodeMCU
            } else if (message == "D0on:success") {
              D0status = true;
            } else if (message == "D0off:success") {
              D0status = false;
            } else if (message == "D1on:success") {
              D1status = true;
            } else if (message == "D1off:success") {
              D1status = false;
            } else if (message == "D2on:success") {
              D2status = true;
            } else if (message == "D2off:success") {
              D2status = false;
            } else if (message == "D2slow:success") {
              D2level = "slow";
            } else if (message == "D2moderate:success") {
              D2level = "moderate";
            } else if (message == "D2fast:success") {
              D2level = "fast";
            } else if (message == "D3on:success") {
              D3status = true;
            } else if (message == "D3off:success") {
              D3status = false;
            } else if (message == "D4on:success") {
              D4status = true;
            } else if (message == "D4off:success") {
              D4status = false;
            } else if (message == "D5on:success") {
              D5status = true;
            } else if (message == "D5off:success") {
              D5status = false;
            } else if (message == "D5slow:success") {
              D5level = "slow";
            } else if (message == "D5moderate:success") {
              D5level = "moderate";
            } else if (message == "D5fast:success") {
              D5level = "fast";
            } else if (message == "D6on:success") {
              D6status = true;
            } else if (message == "D6off:success") {
              D6status = false;
            }
          });
        },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      if (D0status == false &&
          cmd != "D0on" &&
          cmd != "D0off" &&
          D1status == false &&
          cmd != "D1on" &&
          cmd != "D1off" &&
          D2status == false &&
          cmd != "D2on" &&
          cmd != "D2off" &&
          cmd != "D2slow" &&
          cmd != "D2moderate" &&
          cmd != "D2fast" &&
          cmd != "D3on" &&
          cmd != "D3off" &&
          D3status == false &&
          cmd != "D4on" &&
          cmd != "D4off" &&
          D4status == false &&
          D5status == false &&
          cmd != "D5on" &&
          cmd != "D5off" &&
          cmd != "D5slow" &&
          cmd != "D5moderate" &&
          cmd != "D5fast" &&
          cmd != "D6on" &&
          cmd != "D6off" &&
          D6status == false) {
        print("Send the valid command");
      } else {
        channel.sink.add(cmd); //sending Command to NodeMCU
      }
    } else {
      channelconnect();
      print("Websocket is not connected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            leading: IconButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(
                Icons.menu,
              ),
            ),
            title: Text("ESP WIZZ"),
            backgroundColor: Colors.black),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: Stack(
                  children: [
                    const Text(
                      'ESP WIZZ',
                      style: TextStyle(color: Colors.white),
                    ),
                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/espp.png"),
                            opacity: 0.5,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('ESP8266 Pinout'),
                onTap: () {
                  Navigator.of(context).push(_createRoute());
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              alignment: Alignment.topCenter,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: -50, right: 50, left: 50, bottom: 50),
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/dha.png"),
                          opacity: 0.3,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                              child: connected
                                  ? const Text("WEBSOCKET: CONNECTED")
                                  : const Text("WEBSOCKET: DISCONNECTED")),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  d0button(),
                                  const SizedBox(width: 30.0),
                                  d1button(),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              d2button(),
                              const SizedBox(width: 30.0),
                              d3button(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              d4button(),
                              const SizedBox(width: 30.0),
                              d5button(),
                            ],
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     d6button(),
                          //     const SizedBox(width: 30.0),
                          //     d7button(),
                          //   ],
                          // ),
                          SizedBox(height: 180.0),
                          Text('NAVTTC',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 60.0,
                                  fontWeight: FontWeight.w900))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Row d0button() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: [
              Text('D0'),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        content: Container(
                          height: 100,
                          width: 250,
                          child: Column(
                            children: [
                              Text(
                                'Enter the name of the button here',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: D0Controller,
                              ),
                            ],
                          ),
                        ),

                        //content: Text(myController.text),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Column(
          children: [
            Container(
              height: 55,
              width: 120,
              margin: const EdgeInsets.only(top: 30),
              child: FlatButton(
                  //button to start scanning
                  // shape: BeveledRectangleBorder(
                  //     side:
                  //         BorderSide(color: Colors.black, width: 2.5),
                  //     borderRadius: BorderRadius.circular(10.0)),

                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  colorBrightness: Brightness.dark,
                  onPressed: () {
                    //on button press
                    if (D0status) {
                      //if ledstatus is true, then turn off the led
                      //if led is on, turn off
                      sendcmd("D0off");
                      D0status = false;
                    } else {
                      //if ledstatus is false, then turn on the led
                      //if led is off, turn on
                      sendcmd("D0on");
                      D0status = true;
                    }
                    setState(() {});
                  },

                  //color: pp == 0 ? Colors.black : Colors.amber,

                  color: D0status ? Colors.green : Colors.red,
                  child: Text(D0Controller.text)),
            ),
            const SizedBox(
              height: 5.0,
            ),
            D0status
                ? Text(D0Controller.text + " is ON")
                : Text(D0Controller.text + " is OFF"),
          ],
        ),
      ],
    );
  }

  Row d1button() {
    return Row(
      children: [
        Column(
          children: [
            Container(
              height: 55,
              width: 120,
              margin: EdgeInsets.only(top: 30),
              child: FlatButton(
                //button to start scanning
                // shape: BeveledRectangleBorder(
                //     side:
                //         BorderSide(color: Colors.black, width: 2.5),
                //     borderRadius: BorderRadius.circular(10.0)),

                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                colorBrightness: Brightness.dark,

                onPressed: () {
                  //on button press
                  if (D1status) {
                    //if ledstatus is true, then turn off the led
                    //if led is on, turn off
                    sendcmd("D1off");
                    D1status = false;
                  } else {
                    //if ledstatus is false, then turn on the led
                    //if led is off, turn on
                    sendcmd("D1on");
                    D1status = true;
                  }
                  setState(() {});
                },
                color: D1status ? Colors.green : Colors.red,
                child: D1status
                    ? Text(D1Controller.text)
                    : Text(D1Controller.text),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            D1status
                ? Text(D1Controller.text + " is ON")
                : Text(D1Controller.text + " is OFF")
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: [
              Text('D1'),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        content: Container(
                          height: 100,
                          width: 250,
                          child: Column(
                            children: [
                              Text(
                                'Enter the name of the button here',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: D1Controller,
                              ),
                            ],
                          ),
                        ),

                        //content: Text(myController.text),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row d2button() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: [
              Text('D2'),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return SingleChildScrollView(
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              content: Container(
                                // height: 300,
                                // width: 250,
                                child: Column(
                                  children: [
                                    Text(
                                      'Enter the name of the button here',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    TextField(
                                      controller: D2Controller,
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                    Text(
                                      "Select mode:",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Column(
                                      children: <Widget>[
                                        ListTile(
                                          title: Text('digital'),
                                          leading: Radio<SingingCharacter>(
                                            value: SingingCharacter.digital,
                                            groupValue: _character,
                                            onChanged:
                                                (SingingCharacter? value) {
                                              setState(() {
                                                _character = value;
                                                D2modeA = false;
                                                print(D2modeA);
                                              });
                                            },
                                          ),
                                        ),
                                        ListTile(
                                          title: Text('analog'),
                                          leading: Radio<SingingCharacter>(
                                            value: SingingCharacter.analog,
                                            groupValue: _character,
                                            onChanged:
                                                (SingingCharacter? value) {
                                              setState(() {
                                                _character = value;
                                                D2modeA = true;
                                                print(D2modeA);
                                              });
                                            },
                                          ),
                                        ),
                                        D2modeA
                                            ? const Divider(
                                                height: 3,
                                                thickness: 1,
                                                indent: 0,
                                                endIndent: 0,
                                                color: Colors.grey,
                                              )
                                            : const Text(""),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        D2modeA
                                            ? const Text(
                                                "Select Level",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              )
                                            : const Text(""),
                                        D2modeA
                                            ? ListTile(
                                                title: const Text('slow'),
                                                leading:
                                                    Radio<SingingCharacter2>(
                                                  value: SingingCharacter2.slow,
                                                  groupValue: _level,
                                                  onChanged: (SingingCharacter2?
                                                      value) {
                                                    setState(() {
                                                      _level = value;
                                                      D2level = "slow";
                                                      print(D2level);
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(""),
                                        D2modeA
                                            ? ListTile(
                                                title: Text('moderate'),
                                                leading:
                                                    Radio<SingingCharacter2>(
                                                  value: SingingCharacter2
                                                      .moderate,
                                                  groupValue: _level,
                                                  onChanged: (SingingCharacter2?
                                                      value) {
                                                    setState(() {
                                                      _level = value;
                                                      D2level = "moderate";
                                                      print(D2level);
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(""),
                                        D2modeA
                                            ? ListTile(
                                                title: Text('fast'),
                                                leading:
                                                    Radio<SingingCharacter2>(
                                                  value: SingingCharacter2.fast,
                                                  groupValue: _level,
                                                  onChanged: (SingingCharacter2?
                                                      value) {
                                                    setState(() {
                                                      _level = value;
                                                      D2level = "fast";
                                                      print(D2level);
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(""),
                                        D2modeA
                                            ? ListTile(
                                                title: Text('on'),
                                                leading:
                                                    Radio<SingingCharacter2>(
                                                  value: SingingCharacter2.on,
                                                  groupValue: _level,
                                                  onChanged: (SingingCharacter2?
                                                      value) {
                                                    setState(() {
                                                      _level = value;
                                                      D2level = "on";
                                                      print(D2level);
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(""),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Column(
          children: [
            Container(
              height: 55,
              width: 120,
              margin: EdgeInsets.only(top: 30),
              child: FlatButton(
                  //button to start scanning
                  // shape: BeveledRectangleBorder(
                  //     side:
                  //         BorderSide(color: Colors.black, width: 2.5),
                  //     borderRadius: BorderRadius.circular(10.0)),

                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  colorBrightness: Brightness.dark,
                  onPressed: () {
                    //on button press
                    if (D2modeA == false) {
                      if (D2status == true) {
                        sendcmd("D2off");
                        D2status = false;
                      } else if (D2status == false) {
                        sendcmd("D2on");
                        D2status = true;
                      }
                    } else if (D2modeA = true) {
                      if ((D2level == "slow") && (D2status == false)) {
                        sendcmd("D2slow");
                        D2status = true;
                      } else if ((D2level == "moderate") &&
                          (D2status == false)) {
                        sendcmd("D2moderate");
                        D2status = true;
                      } else if ((D2level == "fast") && (D2status == false)) {
                        sendcmd("D2fast");
                        D2status = true;
                      } else if ((D2level == "on") && (D2status == false)) {
                        sendcmd("D2on");
                        D2status = true;
                      } else if (D2status = true) {
                        sendcmd("D2off");
                        D2status = false;
                      }
                    }
                    setState(() {});
                  },
                  color: D2status ? Colors.green : Colors.red,
                  child: Text(D2Controller.text)),
            ),
            SizedBox(
              height: 5.0,
            ),
            D2status
                ? Text(D2Controller.text + " is ON")
                : Text(D2Controller.text + " is OFF"),
          ],
        ),
      ],
    );
  }

  Row d3button() {
    return Row(
      children: [
        Column(
          children: [
            Container(
              height: 55,
              width: 120,
              margin: EdgeInsets.only(top: 30),
              child: FlatButton(
                //button to start scanning
                // shape: BeveledRectangleBorder(
                //     side:
                //         BorderSide(color: Colors.black, width: 2.5),
                //     borderRadius: BorderRadius.circular(10.0)),

                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                colorBrightness: Brightness.dark,

                onPressed: () {
                  //on button press
                  if (D3status) {
                    //if ledstatus is true, then turn off the led
                    //if led is on, turn off
                    sendcmd("D3off");
                    D3status = false;
                  } else {
                    //if ledstatus is false, then turn on the led
                    //if led is off, turn on
                    sendcmd("D3on");
                    D3status = true;
                  }
                  setState(() {});
                },
                color: D3status ? Colors.green : Colors.red,
                child: D3status
                    ? Text(D3Controller.text)
                    : Text(D3Controller.text),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            D3status
                ? Text(D3Controller.text + " is ON")
                : Text(D3Controller.text + " is OFF")
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: [
              const Text('D3'),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        content: Container(
                          height: 100,
                          width: 250,
                          child: Column(
                            children: [
                              const Text(
                                'Enter the name of the button here',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: D3Controller,
                              ),
                            ],
                          ),
                        ),

                        //content: Text(myController.text),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row d4button() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: [
              Text('D4'),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        content: Container(
                          height: 100,
                          width: 250,
                          child: Column(
                            children: [
                              Text(
                                'Enter the name of the button here',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: D4Controller,
                              ),
                            ],
                          ),
                        ),

                        //content: Text(myController.text),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Column(
          children: [
            Container(
              height: 55,
              width: 120,
              margin: EdgeInsets.only(top: 30),
              child: FlatButton(
                //button to start scanning
                // shape: BeveledRectangleBorder(
                //     side:
                //         BorderSide(color: Colors.black, width: 2.5),
                //     borderRadius: BorderRadius.circular(10.0)),

                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                colorBrightness: Brightness.dark,

                onPressed: () {
                  //on button press
                  if (D4status) {
                    //if ledstatus is true, then turn off the led
                    //if led is on, turn off
                    sendcmd("D4off");
                    D4status = false;
                  } else {
                    //if ledstatus is false, then turn on the led
                    //if led is off, turn on
                    sendcmd("D4on");
                    D4status = true;
                  }
                  setState(() {});
                },
                color: D4status ? Colors.green : Colors.red,
                child: D4status
                    ? Text(D4Controller.text)
                    : Text(D4Controller.text),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            D4status
                ? Text(D4Controller.text + " is ON")
                : Text(D4Controller.text + " is OFF")
          ],
        ),
      ],
    );
  }

  Row d5button() {
    return Row(
      children: [
        Column(
          children: [
            Container(
              height: 55,
              width: 120,
              margin: EdgeInsets.only(top: 30),
              child: FlatButton(
                  //button to start scanning
                  // shape: BeveledRectangleBorder(
                  //     side:
                  //         BorderSide(color: Colors.black, width: 2.5),
                  //     borderRadius: BorderRadius.circular(10.0)),

                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  colorBrightness: Brightness.dark,
                  onPressed: () {
                    //on button press
                    if (D5modeA == false) {
                      if (D5status == true) {
                        sendcmd("D5off");
                        D5status = false;
                      } else if (D5status == false) {
                        sendcmd("D5on");
                        D5status = true;
                      }
                    } else if (D5modeA = true) {
                      if ((D5level == "slow") && (D5status == false)) {
                        sendcmd("D5slow");
                        D5status = true;
                      } else if ((D5level == "moderate") &&
                          (D5status == false)) {
                        sendcmd("D5moderate");
                        D5status = true;
                      } else if ((D5level == "fast") && (D5status == false)) {
                        sendcmd("D5fast");
                        D5status = true;
                      } else if ((D5level == "on") && (D5status == false)) {
                        sendcmd("D5on");
                        D5status = true;
                      } else if (D5status = true) {
                        sendcmd("D5off");
                        D5status = false;
                      }
                    }
                    setState(() {});
                  },
                  color: D5status ? Colors.green : Colors.red,
                  child: Text(D5Controller.text)),
            ),
            SizedBox(
              height: 5.0,
            ),
            D5status
                ? Text(D5Controller.text + " is ON")
                : Text(D5Controller.text + " is OFF"),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: [
              Text('D5'),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return SingleChildScrollView(
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              content: Container(
                                // height: 300,
                                // width: 250,
                                child: Column(
                                  children: [
                                    Text(
                                      'Enter the name of the button here',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    TextField(
                                      controller: D5Controller,
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                    Text(
                                      "Select mode:",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Column(
                                      children: <Widget>[
                                        ListTile(
                                          title: Text('digital'),
                                          leading: Radio<SingingCharacter>(
                                            value: SingingCharacter.digital,
                                            groupValue: _character,
                                            onChanged:
                                                (SingingCharacter? value) {
                                              setState(() {
                                                _character = value;
                                                D5modeA = false;
                                                print(D5modeA);
                                              });
                                            },
                                          ),
                                        ),
                                        ListTile(
                                          title: Text('analog'),
                                          leading: Radio<SingingCharacter>(
                                            value: SingingCharacter.analog,
                                            groupValue: _character,
                                            onChanged:
                                                (SingingCharacter? value) {
                                              setState(() {
                                                _character = value;
                                                D5modeA = true;
                                                print(D5modeA);
                                              });
                                            },
                                          ),
                                        ),
                                        D5modeA
                                            ? const Divider(
                                                height: 3,
                                                thickness: 1,
                                                indent: 0,
                                                endIndent: 0,
                                                color: Colors.grey,
                                              )
                                            : const Text(""),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        D5modeA
                                            ? const Text(
                                                "Select Level",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              )
                                            : const Text(""),
                                        D5modeA
                                            ? ListTile(
                                                title: const Text('slow'),
                                                leading:
                                                    Radio<SingingCharacter2>(
                                                  value: SingingCharacter2.slow,
                                                  groupValue: _level,
                                                  onChanged: (SingingCharacter2?
                                                      value) {
                                                    setState(() {
                                                      _level = value;
                                                      D5level = "slow";
                                                      print(D5level);
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(""),
                                        D5modeA
                                            ? ListTile(
                                                title: Text('moderate'),
                                                leading:
                                                    Radio<SingingCharacter2>(
                                                  value: SingingCharacter2
                                                      .moderate,
                                                  groupValue: _level,
                                                  onChanged: (SingingCharacter2?
                                                      value) {
                                                    setState(() {
                                                      _level = value;
                                                      D5level = "moderate";
                                                      print(D5level);
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(""),
                                        D5modeA
                                            ? ListTile(
                                                title: Text('fast'),
                                                leading:
                                                    Radio<SingingCharacter2>(
                                                  value: SingingCharacter2.fast,
                                                  groupValue: _level,
                                                  onChanged: (SingingCharacter2?
                                                      value) {
                                                    setState(() {
                                                      _level = value;
                                                      D5level = "fast";
                                                      print(D5level);
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(""),
                                        D5modeA
                                            ? ListTile(
                                                title: Text('on'),
                                                leading:
                                                    Radio<SingingCharacter2>(
                                                  value: SingingCharacter2.on,
                                                  groupValue: _level,
                                                  onChanged: (SingingCharacter2?
                                                      value) {
                                                    setState(() {
                                                      _level = value;
                                                      D5level = "on";
                                                      print(D5level);
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(""),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row d6button() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: [
              Text('D6'),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return SingleChildScrollView(
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              content: Container(
                                // height: 300,
                                // width: 250,
                                child: Column(
                                  children: [
                                    Text(
                                      'Enter the name of the button here',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    TextField(
                                      controller: D6Controller,
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                    Text(
                                      "Select mode:",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Column(
                                      children: <Widget>[
                                        ListTile(
                                          title: Text('digital'),
                                          leading: Radio<SingingCharacter>(
                                            value: SingingCharacter.digital,
                                            groupValue: _character,
                                            onChanged:
                                                (SingingCharacter? value) {
                                              setState(() {
                                                _character = value;
                                                D6modeA = false;
                                                print(D6modeA);
                                              });
                                            },
                                          ),
                                        ),
                                        ListTile(
                                          title: Text('analog'),
                                          leading: Radio<SingingCharacter>(
                                            value: SingingCharacter.analog,
                                            groupValue: _character,
                                            onChanged:
                                                (SingingCharacter? value) {
                                              setState(() {
                                                _character = value;
                                                D6modeA = true;
                                                print(D6modeA);
                                              });
                                            },
                                          ),
                                        ),
                                        D6modeA
                                            ? const Divider(
                                                height: 3,
                                                thickness: 1,
                                                indent: 0,
                                                endIndent: 0,
                                                color: Colors.grey,
                                              )
                                            : const Text(""),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        D6modeA
                                            ? const Text(
                                                "Select Level",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              )
                                            : const Text(""),
                                        D6modeA
                                            ? ListTile(
                                                title: const Text('slow'),
                                                leading:
                                                    Radio<SingingCharacter2>(
                                                  value: SingingCharacter2.slow,
                                                  groupValue: _level,
                                                  onChanged: (SingingCharacter2?
                                                      value) {
                                                    setState(() {
                                                      _level = value;
                                                      D6level = "slow";
                                                      print(D6level);
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(""),
                                        D6modeA
                                            ? ListTile(
                                                title: Text('moderate'),
                                                leading:
                                                    Radio<SingingCharacter2>(
                                                  value: SingingCharacter2
                                                      .moderate,
                                                  groupValue: _level,
                                                  onChanged: (SingingCharacter2?
                                                      value) {
                                                    setState(() {
                                                      _level = value;
                                                      D6level = "moderate";
                                                      print(D6level);
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(""),
                                        D6modeA
                                            ? ListTile(
                                                title: Text('fast'),
                                                leading:
                                                    Radio<SingingCharacter2>(
                                                  value: SingingCharacter2.fast,
                                                  groupValue: _level,
                                                  onChanged: (SingingCharacter2?
                                                      value) {
                                                    setState(() {
                                                      _level = value;
                                                      D6level = "fast";
                                                      print(D6level);
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(""),
                                        D6modeA
                                            ? ListTile(
                                                title: Text('on'),
                                                leading:
                                                    Radio<SingingCharacter2>(
                                                  value: SingingCharacter2.on,
                                                  groupValue: _level,
                                                  onChanged: (SingingCharacter2?
                                                      value) {
                                                    setState(() {
                                                      _level = value;
                                                      D6level = "on";
                                                      print(D6level);
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(""),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Column(
          children: [
            Container(
              height: 55,
              width: 120,
              margin: EdgeInsets.only(top: 30),
              child: FlatButton(
                  //button to start scanning
                  // shape: BeveledRectangleBorder(
                  //     side:
                  //         BorderSide(color: Colors.black, width: 2.5),
                  //     borderRadius: BorderRadius.circular(10.0)),

                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  colorBrightness: Brightness.dark,
                  onPressed: () {
                    //on button press
                    if (D6modeA == false) {
                      if (D5status == true) {
                        sendcmd("D6off");
                        D6status = false;
                      } else if (D6status == false) {
                        sendcmd("D6on");
                        D6status = true;
                      }
                    } else if (D6modeA = true) {
                      if ((D6level == "slow") && (D6status == false)) {
                        sendcmd("D6slow");
                        D6status = true;
                      } else if ((D6level == "moderate") &&
                          (D6status == false)) {
                        sendcmd("D6moderate");
                        D6status = true;
                      } else if ((D6level == "fast") && (D6status == false)) {
                        sendcmd("D6fast");
                        D6status = true;
                      } else if ((D6level == "on") && (D6status == false)) {
                        sendcmd("D6on");
                        D6status = true;
                      } else if (D6status = true) {
                        sendcmd("D6off");
                        D6status = false;
                      }
                    }
                    setState(() {});
                  },
                  color: D6status ? Colors.green : Colors.red,
                  child: Text(D6Controller.text)),
            ),
            SizedBox(
              height: 5.0,
            ),
            D6status
                ? Text(D6Controller.text + " is ON")
                : Text(D6Controller.text + " is OFF"),
          ],
        ),
      ],
    );
  }

  Row d7button() {
    return Row(
      children: [
        Column(
          children: [
            Container(
              height: 55,
              width: 120,
              margin: EdgeInsets.only(top: 30),
              child: FlatButton(
                //button to start scanning
                // shape: BeveledRectangleBorder(
                //     side:
                //         BorderSide(color: Colors.black, width: 2.5),
                //     borderRadius: BorderRadius.circular(10.0)),

                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                colorBrightness: Brightness.dark,

                onPressed: () {
                  //on button press
                  if (D7status) {
                    //if ledstatus is true, then turn off the led
                    //if led is on, turn off
                    sendcmd("D7off");
                    D7status = false;
                  } else {
                    //if ledstatus is false, then turn on the led
                    //if led is off, turn on
                    sendcmd("D7on");
                    D7status = true;
                  }
                  setState(() {});
                },
                color: D7status ? Colors.green : Colors.red,
                child: D7status
                    ? Text(D7Controller.text)
                    : Text(D7Controller.text),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            D6status
                ? Text(D7Controller.text + " is ON")
                : Text(D7Controller.text + " is OFF")
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: [
              Text('D7'),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        content: Container(
                          height: 100,
                          width: 250,
                          child: Column(
                            children: [
                              Text(
                                'Enter the name of the button here',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: D7Controller,
                              ),
                            ],
                          ),
                        ),

                        //content: Text(myController.text),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
