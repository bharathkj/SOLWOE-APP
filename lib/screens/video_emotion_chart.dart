import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class VideoEmotionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchData(), // Fetch data with current user's email
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

  Future<List<ScatterSpot>> _fetchData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }
    String? userEmail = currentUser.email;


    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('emotions')
        .get();

    List<ScatterSpot> dataPoints = [];

    querySnapshot.docs.forEach((doc) {
      var emotionData = doc['emotion'];
      var timestamp = doc['timestamp'];

      if (emotionData != null && timestamp != null) {
        double calculatedEmotionValue = _mapEmotionStringToValue(emotionData);

        double timestampValue = (timestamp as Timestamp).millisecondsSinceEpoch.toDouble() / 1000;

        dataPoints.add(ScatterSpot(timestampValue, calculatedEmotionValue));
      }
    });

    return dataPoints;
  }

  double _mapEmotionStringToValue(String emotionString) {
    switch (emotionString.toLowerCase()) {
      case 'happy':
        return 1.0;
      case 'neutral':
        return 0.5;
      case 'sad':
        return 0.0;
      case 'surprise':
        return 0.75;
      case 'disgust':
        return 0.35;
      case 'angry':
        return 0.2;
      case 'fear':
        return 0.1;
      default:
        return 0.5; // Default value for unknown emotions
    }
  }
}
