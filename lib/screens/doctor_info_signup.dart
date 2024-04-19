import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorInfoPage extends StatefulWidget {
  @override
  _DoctorInfoPageState createState() => _DoctorInfoPageState();
}

class _DoctorInfoPageState extends State<DoctorInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _salutationController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();


  Future<void> _submitData() async {
    // Get current user's phone number
    final currentUserPhoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber;

    // Create a new document in the 'doctors' collection using the phone number as document ID
    await FirebaseFirestore.instance.collection('doctors').doc(_phoneController.text).set({
      'name': _nameController.text,
      'gender': _genderController.text,
      'salutation': 'Dr.',
      'speciality': _specialityController.text,
      'address': _feeController.text,
      'city': 'a',
      'category': _categoryController.text,
      'consultation': '2',
      'count': '0',
      'onboarding': true, // assuming this is always true for new entries
      'fee': _feeController.text, // convert _feeController to string
      'phone': _phoneController.text,
      // Slots, Ratings, and Location remain the same for all documents
      'slots': {
        'lunch': {'start time': '12:00', 'end time': '14:00'},
        'weekday': {'start time': '09:00', 'end time': '17:00'},
        'weekend': {'start time': '09:00', 'end time': '14:00'},
      },
      'ratings': {'like': 0, 'dislike': 0},
      'location': {'a': 'address', 'b': 'city', '7': 'pin code', 'd': 'state'}, // Replace 'address', 'city', 'pin code', 'state' with actual values if needed
    });

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Data Submitted'),
          content: Text('Your information has been submitted successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _genderController,
              decoration: InputDecoration(labelText: 'Gender'),
            ),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextFormField(
              controller: _specialityController,
              decoration: InputDecoration(labelText: 'Speciality'),
            ),
            TextFormField(
              controller: _feeController,
              decoration: InputDecoration(labelText: 'Fee'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Show confirmation dialog before submitting data
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Submission'),
                      content: Text('Are you sure you want to submit this data?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _submitData();
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
