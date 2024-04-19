// services/firebase_service.dart
/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solwoe/model/emotion_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static Future<List<EmotionData>> fetchEmotionData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot<Map<String, dynamic>> userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        String username = userDoc['username'];
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(username)
            .collection('textemotion')
            .get();

        List<EmotionData> emotionDataList = querySnapshot.docs.map((doc) {
          Map<String, dynamic> emotions = Map<String, double>.from(doc['emotion']);
          return EmotionData(
            emotions: emotions,
            timestamp: (doc['timestamp'] as Timestamp).toDate(),
          );
        }).toList();

        return emotionDataList;
      }
    }

    return [];
  }
}
*/