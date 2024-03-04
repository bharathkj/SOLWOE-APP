// video_emotion_chart.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class VideoEmotionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchData('bharath', 'emotions'), // Replace 'bharath' with the actual username
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<ScatterSpot> dataPoints = snapshot.data as List<ScatterSpot>;

          return Center(
            child: ScatterChart(
              ScatterChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(),
                  bottomTitles: AxisTitles(),
                ),
                scatterSpots: dataPoints,
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<ScatterSpot>> fetchData(String username, String collectionName) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc('bharath')
        .collection('emotions')
        .get();

    List<ScatterSpot> dataPoints = [];

    querySnapshot.docs.forEach((doc) {
      var emotionData = doc['emotion'];
      var timestamp = doc['timestamp'];

      if (emotionData != null && timestamp != null) {
        // Example mapping for converting 'emotion' string to numeric value
        double calculatedEmotionValue = mapEmotionStringToValue(emotionData);

        double timestampValue = (timestamp as Timestamp).millisecondsSinceEpoch.toDouble() / 1000; // Convert to seconds

        dataPoints.add(ScatterSpot(timestampValue, calculatedEmotionValue));
      }
    });

    return dataPoints;
  }

  double mapEmotionStringToValue(String emotionString) {
    switch (emotionString.toLowerCase()) {
      case 'happy':
        return 1.0;
      case 'neutral':
        return 0.0;
      case 'sad':
        return -1.0;
      case 'surprise':
        return 0.5;
      case 'disgust':
        return -0.5;
      case 'angry':
        return -0.8;
      case 'fear':
        return -0.2;
      default:
        return 0.0; // Default value for unknown emotions
    }
  }
}

