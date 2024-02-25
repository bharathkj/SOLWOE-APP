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

  @override
  void initState() {
    super.initState();
    cameras = widget.cameras;
    isCameraReady = false;
    _controller = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back),
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
      Uri.parse('http://192.168.29.182:5001/process_frame'),
      headers: {
        'Content-Type': 'application/octet-stream',
      },
      body: imageBytes,
    );

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
            child: ElevatedButton(
              onPressed: () {
                _toggleTimer();
              },
              child: Text(_timer == null ? 'Start / Stop' : 'Stop Timer'),
            ),
          ),
        ],
      ),
    );
  }
}

