// text_emotion_chart.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class TextEmotionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchData('coomestofcoomer@gmail.com', 'textemotion'), // Replace with the actual username
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
        .doc('coomestofcoomer@gmail.com')
        .collection('textemotion')
        .get();

    List<ScatterSpot> dataPoints = [];

    querySnapshot.docs.forEach((doc) {
      var emotionData = doc['emotion'];
      var timestamp = doc['timestamp'];

      if (emotionData != null && timestamp != null) {
        double positive = emotionData['positive'] ?? 0;
        double negative = emotionData['negative'] ?? 0;
        double neutral = emotionData['neutral'] ?? 0;

        double calculatedEmotionValue = (positive + neutral - negative) / 3;

        Timestamp timestamp = doc['timestamp'];
        double timestampValue = timestamp.millisecondsSinceEpoch.toDouble() / 1000; // Convert to seconds

        dataPoints.add(ScatterSpot(timestampValue, calculatedEmotionValue));
      }
    });

    return dataPoints;
  }
}
