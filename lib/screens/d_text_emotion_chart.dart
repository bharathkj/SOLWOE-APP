import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TextEmotionChart extends StatelessWidget {
  final String selectedPatientId; // Declare selectedPatientId variable

  const TextEmotionChart({Key? key, required this.selectedPatientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<FlSpot> dataPoints = snapshot.data as List<FlSpot>;

          return Center(
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(),
                  bottomTitles: AxisTitles(),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPoints,
                    isCurved: true,
                    //colors: [Colors.red], // You can set the color here
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<FlSpot>> fetchData() async {
    // Fetch data for the selected patient
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(selectedPatientId) // Use selectedPatientId to fetch data
        .collection('textemotion')
        .orderBy('timestamp') // Order by timestamp
        .get();

    List<FlSpot> dataPoints = [];

    querySnapshot.docs.forEach((doc) {
      var emotionData = doc['emotion'];
      var timestamp = doc['timestamp'];

      if (emotionData != null && timestamp != null) {
        double negative = emotionData['negative'] ?? 0;

        DateTime dateTime = (timestamp as Timestamp).toDate();
        double timestampValue = dateTime.millisecondsSinceEpoch.toDouble() / 1000; // Convert to seconds

        dataPoints.add(FlSpot(timestampValue, negative));
      }
    });

    return dataPoints;
  }
}
