import 'package:flutter/material.dart';
import 'dart:js' as js;
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  runApp(MaterialApp(
    home: CounterApp(),
  ));
}

class CounterApp extends StatefulWidget {
  @override
  _CounterAppState createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;
  bool isReceivedData = false;

  @override
  void initState() {
    super.initState();
    setupMessageListener();
  }

  void receiveDataFromiOS(String data) {
    setState(() {
      _counter = int.parse(data);
    });
  }

  void setupMessageListener() {
    js.context['receiveDataFromiOS'] = receiveDataFromiOS;
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  void sendDataToiOSApp() {
    js.context.callMethod('sendDataToNativeApp', [_counter]);
  }

  void close() {
    js.context.callMethod('close', []);
  }

  void openCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyCamera()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Demo app')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Counter:',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                '$_counter',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _incrementCounter,
                    child: Icon(Icons.add),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _decrementCounter,
                    child: Icon(Icons.remove),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      sendDataToiOSApp();
                      close();
                    },
                    child: Text('Send value to native'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      openCamera(context);
                    },
                    child: Text('Open camera'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyCamera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebRTCExample(),
    );
  }
}

class WebRTCExample extends StatefulWidget {
  @override
  _WebRTCExampleState createState() => _WebRTCExampleState();
}

class _WebRTCExampleState extends State<WebRTCExample> {
  MediaStream? _localStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initWebRTC();
  }

  void _initWebRTC() async {
    // Get user media (camera stream)
    final mediaStreamConstraints = <String, dynamic>{
      'video': true,
      'audio': false, // Set to true if you want to enable audio as well
    };

    final mediaStream =
        await navigator.mediaDevices.getUserMedia(mediaStreamConstraints);
    setState(() {
      _localStream = mediaStream;
    });

    // Initialize the local renderer to display the camera feed
    await _localRenderer.initialize();
    _localRenderer.srcObject = _localStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebRTC Camera Example'),
      ),
      body: _localRenderer.srcObject != null
          ? RTCVideoView(_localRenderer)// Display the local camera stream
          : Center(
              child: CircularProgressIndicator(),
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     var abc = _localStream!.getVideoTracks().first;
      //     final frame = await abc.captureFrame();

      //           await showDialog(
      //               context: context,
      //               builder: (context) => AlertDialog(
      //                     content: Image.memory(frame.asUint8List(),
      //                         height: 40, width: 40),
      //                     actions: <Widget>[
      //                       TextButton(
      //                         onPressed:
      //                             Navigator.of(context, rootNavigator: true)
      //                                 .pop,
      //                         child: Text('OK'),
      //                       )
      //                     ],
      //                   ));
      //   },
      //   backgroundColor: Colors.red,
      //   child: const Icon(Icons.photo),
      // ),
    );
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _localRenderer.dispose();
    super.dispose();
  }
}
