import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solwoe/screens/doctor_details_screen.dart';

class SearchDoctors extends SearchDelegate {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  String get searchFieldLabel => 'Search doctors';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Perform the search and display results
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('doctors')
          .where('onboarding', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<QueryDocumentSnapshot> doctors = snapshot.data!.docs;
        List<QueryDocumentSnapshot> results = doctors
            .where((doctor) =>
                doctor['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(results[index]['name']),
              subtitle: Text(results[index]['speciality']),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions as user types
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('doctors').where('onboarding',isEqualTo:true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<QueryDocumentSnapshot> doctors = snapshot.data!.docs;
        List<QueryDocumentSnapshot> suggestions = doctors
            .where((doctor) =>
                doctor['name'].toLowerCase().startsWith(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                  '${suggestions[index]['salutation']} ${suggestions[index]['name']}'),
              subtitle: Text(suggestions[index]['speciality']),
              onTap: () {
                query = suggestions[index]['name'];
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        DoctorDetailsScreen(doctor: suggestions[index])));
              },
            );
          },
        );
      },
    );
  }
}
