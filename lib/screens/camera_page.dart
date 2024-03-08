import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  late Timer? _timer; // Use Timer? to allow null
  bool isTimerActive = false; // Indicator for the active timer
  bool isPictureTaken = false; // Indicator for the picture being taken
  String jsonResult = ''; // Variable to hold the JSON result

  // Start the timer
  void _startTimer() {
    if (_timer == null) {
      // Start the timer
      _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) async {
        if (isCameraReady) {
          // Set the indicator to show the picture is being taken
          setState(() {
            isPictureTaken = true;
          });

          await _sendImageFrame();

          // Reset the indicator after a short delay
          _resetPictureTakenIndicator();
        }
      });

      // Update the visual indicator
      setState(() {
        isTimerActive = true;
      });
    }
  }

  // Reset the indicator after a short delay
  void _resetPictureTakenIndicator() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isPictureTaken = false;
      });
    });
  }

  // Stop the timer
  void _stopTimer() {
    if (_timer != null) {
      // Stop the timer
      _timer!.cancel();
      _timer = null;

      // Update the visual indicator
      setState(() {
        isTimerActive = false;
        isPictureTaken = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    cameras = widget.cameras;
    isCameraReady = false;
    _controller = CameraController(
      cameras.firstWhere((camera) =>
      camera.lensDirection == CameraLensDirection.back),
      ResolutionPreset.medium,
    );
    _timer = null; // Initialize _timer to null
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
      Uri.parse('http://192.168.29.182:5000/process_frame'),
      headers: {
        'Content-Type': 'application/octet-stream',
      },
      body: imageBytes,
    );

    // Update the JSON result
    setState(() {
      jsonResult = response.body;
    });

    print('Server Response: ${response.body}');
  }

  // Toggle the timer
  void _toggleTimer() {
    if (_timer == null) {
      // Start the timer
      _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) async {
        if (isCameraReady) {
          await _sendImageFrame();
        }
      });
    } else {
      // Stop the timer
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _disposeController();
    _timer?.cancel(); // Cancel the timer if it's running
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
            color: isPictureTaken ? Colors.green : Colors
                .grey, // Indicator color
          ),
          SizedBox(height: 10), // Add some spacing
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

