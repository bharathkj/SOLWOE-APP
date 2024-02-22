// screens/results_screen.dart
/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:solwoe/model/emotion_data.dart';
import 'package:solwoe/services/firebase_service.dart';

class ResultsScreen extends StatefulWidget {
  final String username;

  ResultsScreen({required this.username});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<List<EmotionData>> emotionDataFuture;

  @override
  void initState() {
    super.initState();
    emotionDataFuture = FirebaseService.fetchEmotionData(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EmotionData>>(
      future: emotionDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return StackedLineChart(
              emotionDataList: snapshot.data!,
            );
          } else {
            // Handle case where no data is available
            return Center(child: Text('No results data available.'));
          }
        } else {
          // Display a loading indicator while fetching data
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
*/