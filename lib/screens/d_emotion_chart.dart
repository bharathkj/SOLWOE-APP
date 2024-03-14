import 'package:flutter/material.dart';
import 'd_text_emotion_chart.dart';
import 'd_video_emotion_chart.dart';

class EmotionChart extends StatefulWidget {
  final String selectedPatientId;

  const EmotionChart({Key? key, required this.selectedPatientId}) : super(key: key);

  @override
  _EmotionChart createState() => _EmotionChart();
}

class _EmotionChart extends State<EmotionChart> {
  int _currentIndex = 0; // 0 for Text Emotion, 1 for Video Emotion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emotion Visualization'),
      ),
      body: _currentIndex == 0
          ? TextEmotionChart(selectedPatientId: widget.selectedPatientId)
          : VideoEmotionChart(selectedPatientId: widget.selectedPatientId),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: 'Text Emotion',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Video Emotion',
          ),
        ],
      ),
    );
  }
}
