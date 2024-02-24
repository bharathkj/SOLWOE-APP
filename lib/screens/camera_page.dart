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

  @override
  void initState() {
    super.initState();
    cameras = widget.cameras;
    isCameraReady = false;
    _controller = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back),
      ResolutionPreset.medium,
    );
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
    final response = await http.post(
      Uri.parse('http://192.168.29.182:5001/process_frame'),
      body: {'image_frame': imageBytes},
    );

    print('Server Response: ${response.body}');
  }

  @override
  void dispose() {
    _disposeController();
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
              onPressed: () async {
                await _sendImageFrame();
              },
              child: Text('Capture frame'),
            ),
          ),
        ],
      ),
    );
  }
}
