import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_uikit/agora_uikit.dart';

import 'package:http/http.dart';

const appId = 'YOUR_API_KEY';


class VideoConsultationScreen extends StatefulWidget {
  final String channelName;
  const VideoConsultationScreen({super.key, required this.channelName});

  @override
  State<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  late final AgoraClient _client;
  bool _loading = true;
  String tempToken = "";

  @override
  void initState() {
    super.initState();
    getToken();
  }

  Future<void> getToken() async {
    String link =
        "YOUR_TOKEN_SERVER_URL";

    Response response = await get(Uri.parse(link));
    Map data = jsonDecode(response.body);
    setState(() {
      tempToken = data["token"];
    });
    AgoraClient client = AgoraClient(
        agoraEventHandlers: AgoraRtcEventHandlers(
          onLeaveChannel: (connection, stats) {
            Navigator.of(context).pop();
          },
        ),
        agoraConnectionData: AgoraConnectionData(
          appId: appId,
          tempToken: tempToken,
          channelName: widget.channelName,
        ),
        enabledPermission: [Permission.camera, Permission.microphone]);
    Future.delayed(const Duration(seconds: 1))
        .then(
          (value) => setState(() {
            _client = client;
            _loading = false;
          }),
        )
        .then((value) => initAgora());
  }

  void initAgora() async {
    await _client.initialize();
  }

  void _showPaymentDialog() async {
    TextEditingController? amount;
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Enter extra charge'),
        content: TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Amount',
            hintText: 'Enter extra charge amount',
          ),
          onChanged: (value) => amount!.text = value,
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Pay now'),
            onPressed: () {
              // Navigate to payment screen
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    log(amount!.text);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Consultation'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  AgoraVideoViewer(
                    client: _client,
                    layoutType: Layout.oneToOne,
                    enableHostControls: true,
                  ),
                  AgoraVideoButtons(
                    client: _client,
                    onDisconnect: () async {
                      await _client.engine.release();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
