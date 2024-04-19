import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase app
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraPage(cameras: cameras),
    );
  }
}

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  late bool isCameraReady;
  late Timer? _timer;
  bool isTimerActive = false;
  bool isPictureTaken = false;
  String jsonResult = '';
  String serverIpAddress = ''; // Initial IP address

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch IP address from Firestore
  Future<void> fetchServerIpAddress() async {
    final docSnapshot = await FirebaseFirestore.instance.collection('config').doc('server').get();
    if (docSnapshot.exists) {
      setState(() {
        serverIpAddress = docSnapshot.data()?['emote'] ?? ''; // Get IP address from 'emote' field
      });
    } else {
      print('Server document does not exist!');
    }
  }

  void _startTimer() {
    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) async {
        if (isCameraReady) {
          setState(() {
            isPictureTaken = true;
          });

          await _sendImageFrame();

          _resetPictureTakenIndicator();
        }
      });

      setState(() {
        isTimerActive = true;
      });
    }
  }

  void _resetPictureTakenIndicator() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isPictureTaken = false;
      });
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;

      setState(() {
        isTimerActive = false;
        isPictureTaken = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchServerIpAddress(); // Fetch IP address when the widget initializes
    cameras = widget.cameras;
    isCameraReady = false;
    _controller = CameraController(
      cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back),
      ResolutionPreset.medium,
    );
    _timer = null;
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller.initialize();
    if (mounted) {
      setState(() {
        isCameraReady = true;
      });
    }
  }

  Future<void> _disposeController() async {
    await _controller.dispose();
  }

  Future<void> _sendImageFrame() async {
    print('Sending image frame...');
    if (!_controller.value.isInitialized) {
      print('Controller not initialized!');
      return;
    }

    XFile imageFile;
    try {
      imageFile = await _controller.takePicture();
    } catch (e) {
      print('Error taking picture: $e');
      return;
    }

    final imageBytes = await imageFile.readAsBytes();
    print("Printing image bytes");

    final response = await http.post(
      Uri.parse('$serverIpAddress/process_frame'),
      headers: {
        'Content-Type': 'application/octet-stream',
      },
      body: imageBytes,
    );

    // Decode JSON response
    final Map<String, dynamic> decodedResponse = json.decode(response.body);

    // Save emotion result to Firestore
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;
    if (userEmail != null) {
      await _firestore.collection('users').doc(userEmail).collection('emotions').add({
        'timestamp': Timestamp.now(),
        'emotion': decodedResponse['dominant_emotion'],
      });
    }

    setState(() {
      jsonResult = response.body;
    });

    print('Server Response: ${response.body}');
  }

  void _toggleTimer() {
    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) async {
        if (isCameraReady) {
          await _sendImageFrame();
        }
      });
    } else {
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _disposeController();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Page'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: isCameraReady
                  ? CameraPreview(_controller)
                  : Center(child: CircularProgressIndicator()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _startTimer();
                  },
                  child: Text('Start Timer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _stopTimer();
                  },
                  child: Text('Stop Timer'),
                ),
              ],
            ),
          ),
          Container(
            height: 20.0,
            width: double.infinity,
            color: isPictureTaken ? Colors.green : Colors.grey,
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              '$jsonResult',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
