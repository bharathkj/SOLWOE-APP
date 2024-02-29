import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmotionChart extends StatefulWidget {
  @override
  _EmotionChartState createState() => _EmotionChartState();
}

class _EmotionChartState extends State<EmotionChart> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  List<FlSpot> neutralData = [];
  List<FlSpot> positiveData = [];
  List<FlSpot> negativeData = [];
  String? _currentUsername;



  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    // Get the currently logged-in user's username
    _currentUsername = await _authService.getCurrentUsername();

    if (_currentUsername != null) {
      fetchData();
    }
  }

  void fetchData() async {
    // Replace '_currentUsername' with the actual username
    String username = _currentUsername!;
    CollectionReference userCollection =
    _firestore.collection('users/coomestofcoomer@gmail.com/textemotion');

    QuerySnapshot querySnapshot = await userCollection.get();

    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> emotionData = doc['emotion'];
      Timestamp timestamp = doc['timestamp'];

      double neutral = emotionData['neutral'];
      double positive = emotionData['positive'];
      double negative = emotionData['negative'];

      neutralData.add(FlSpot(timestamp.seconds.toDouble(), neutral));
      positiveData.add(FlSpot(timestamp.seconds.toDouble(), positive));
      negativeData.add(FlSpot(timestamp.seconds.toDouble(), negative));
    });

    // After fetching the data, trigger a redraw
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUsername == null) {
      // Display a loading indicator or handle the case where the username is not available yet
      return CircularProgressIndicator();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Emotion Chart - $_currentUsername'),
      ),
      body: Center(
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: true),
            gridData: FlGridData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: neutralData,
                isCurved: true,
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: positiveData,
                isCurved: true,
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: negativeData,
                isCurved: true,
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the currently logged-in user
  User? get currentUser => _auth.currentUser;

  // Get the currently logged-in user's username
  Future<String?> getCurrentUsername() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Replace 'users' and 'textemotion' with the actual collection names
      CollectionReference userCollection = FirebaseFirestore.instance
          .collection('users').doc('coomestofcoomer@gmail.com').collection(
          'textemotion');
      QuerySnapshot querySnapshot = await userCollection
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String? username = await querySnapshot.docs.first.reference.parent.parent?.get().then(
              (doc) {
            if (doc.exists && doc.data() != null) {
              // Assuming 'username' is a field within the document
              return doc.data()!['username'];
            } else {
              // Handle the case where the document does not exist or 'username' field is not present
              return null;
            }
          },
        );
        return username;
      }
    }

    return null;
  }

}