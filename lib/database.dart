import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:solwoe/auth.dart';

class Database {

  Future<void> saveDoctorData(Map<String, dynamic> doctorData) async {
    try {
      await FirebaseFirestore.instance.collection('doctors').add(doctorData);
    } catch (e) {
      print('Error saving doctor data: $e');
      throw e; // Rethrow the error to handle it at the caller's level if needed
    }
  }

  Future<bool> checkIfDocumentExists(String documentId) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('users');
      var doc = await collectionRef.doc(documentId).get();
      if (!doc.exists) {
        createDocument(documentId);
      }
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> createDocument(String documentId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(documentId)
        .set({'onboarding': false});
  }

  Future<Map<String, dynamic>> isOnboardingDone(String documentId) async {
    await checkIfDocumentExists(documentId);
    var collectionRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(documentId)
        .get();
    Map<String, dynamic> value = collectionRef.data()!;
    return {'onboarding': value['onboarding']};
  }

  Future<void> setProfile(Map<String, dynamic> json) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(json['email'])
        .set({
      'dateOfBirth': json['dateOfBirth'],
      'email': json['email'],
      'gender': json['gender'],
      'role': json['role'],
      'onboarding': true,
      'name': json['name'],
      'location': {
        'city': json['city'],
        'state': json['state'],
        'country': json['country'],
      },
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile(documentId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(documentId)
        .get();
  }

  Future<void> saveAssessmentAnswers(
      List<Map<String, String>> answers,
      String total,
      String result,
      String documentId,
      String date,
      String time,
      String suggestion) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.email.toString())
        .collection('assessment')
        .doc(documentId)
        .set({
      'answers': answers,
      'total_score': total,
      'result': result,
      'date': date,
      'time': time,
      'suggestion': suggestion
    });
  }

  Future<void> saveMood(String mood, int value, String date) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.email.toString())
        .collection('moodtracker')
        .doc(date)
        .set({'mood': mood, 'value': value, 'date': date});
  }

  Future<QuerySnapshot> getMood() async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.email.toString())
        .collection('moodtracker')
        .orderBy('date', descending: true)
        .limit(4)
        .get();
    return query;
  }

  Future<void> bookAppointmentCollection({
    String? doctorName,
    String? doctorId,
    String? patientName,
    String? patientAge,
    String? patientGender,
    String? patientId,
    String? date,
    String? time,
    String? appointmentId,
    String? type,
    Map<dynamic, dynamic>? assessment,
  }) async {
    if (assessment != null) {
      await FirebaseFirestore.instance.collection('appointments').add({
        'doctor_name': doctorName,
        'doctor_id': doctorId,
        'patient_name': patientName,
        'patient_age': patientAge,
        'patient_gender': patientGender,
        'patient_id': patientId,
        'date': date,
        'time': time,
        'status': 'booked',
        'appointmentId': appointmentId,
        'type': type,
        'assessment': assessment,
      });
    } else {
      await FirebaseFirestore.instance.collection('appointments').add({
        'doctor_name': doctorName,
        'doctor_id': doctorId,
        'patient_name': patientName,
        'patient_id': patientId,
        'patient_age': patientAge,
        'patient_gender': patientGender,
        'date': date,
        'time': time,
        'status': 'booked',
        'appointmentId': appointmentId,
        'type': type,
      });
    }
  }

  Future<void> cancelAppointmentCollection(String docId) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(docId)
        .update({'status': 'cancelled'});
  }

  Future<void> cancelAppointmentRealtime(
      String doctorId, String date, String appointmentId) async {
    await FirebaseDatabase.instance
        .ref()
        .child('appointments')
        .child(doctorId)
        .child(date)
        .child(appointmentId)
        .remove();
  }

  Future<String> addAppointmentRealtime(
      String docId, String patientId, String date, String slot) async {
    DatabaseReference appointmentRef = FirebaseDatabase.instance
        .ref()
        .child('appointments')
        .child(docId)
        .child(date);
    String? appointmentId;
    final ref = appointmentRef.orderByChild('slot').equalTo(slot);
    final snapshot = await ref.once();
    if (snapshot.snapshot.value != null) {
      Map appointmentKey = snapshot.snapshot.value as Map;
      appointmentKey.forEach((key, value) async {
        appointmentId = key;
        await appointmentRef.child(key).update({
          'doctorId': docId,
          'patientId': patientId,
          'isAvailable': false,
          'isBooked': true,
          'slot': slot,
        });
      });
    } else {
      await appointmentRef.push().set({
        'doctorId': docId,
        'patientId': patientId,
        'isAvailable': false,
        'isBooked': true,
        'slot': slot,
        // other relevant data
      });
      appointmentId = appointmentRef.key!;
    }

    return appointmentId.toString();
  }
}
