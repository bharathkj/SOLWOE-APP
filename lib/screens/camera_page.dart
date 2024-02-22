import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
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
  late bool isDetecting;

  @override
  void initState() {
    super.initState();
    cameras = widget.cameras;
    isCameraReady = false;
    isDetecting = false;
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

  Future<void> _startDetecting() async {
    if (!isDetecting) {
      const period = Duration(seconds: 3);
      Timer.periodic(period, (Timer timer) async {
        if (isDetecting) {
          await _sendImageFrame();
        }
      });
    }
  }

  Future<void> _stopDetecting() async {
    setState(() {
      isDetecting = false;
    });
  }

  Future<void> _sendImageFrame() async {
    if (!_controller.value.isInitialized) {
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    if (isCameraReady && !isDetecting) {
                      await _startDetecting();
                    } else {
                      await _stopDetecting();
                    }
                    setState(() {
                      isDetecting = !isDetecting;
                    });
                  },
                  child: Text(isDetecting ? 'Stop Detecting' : 'Start Detecting'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }
}



/*import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    // Initialize the camera controller and fetch the available cameras
    _initializeCamera();
  }

  void _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController.value.isInitialized) {
      return CircularProgressIndicator(); // or any loading indicator
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera View'),
      ),
      body: CameraPreview(_cameraController),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic to start and stop the camera
          // For simplicity, you can toggle the camera state on button press
          setState(() {
            if (_cameraController.value.isRecordingVideo) {
              _cameraController.stopVideoRecording();
            } else {
              _cameraController.startVideoRecording();
            }
          });
        },
        child: Icon(
          _cameraController.value.isRecordingVideo
              ? Icons.stop
              : Icons.videocam,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
*/


