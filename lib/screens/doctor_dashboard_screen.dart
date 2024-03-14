import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:solwoe/model/appointment.dart';
import 'package:solwoe/model/user.dart';
import 'package:solwoe/screens/d_emotion_chart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  //String selectedEmail = "coomestofcoomer@gmail.com";
  String selectedPatientId = ""; // Initialize with empty string
  List<String> patientIds = []; // List to store patient IDs

  @override
  void initState() {
    super.initState();
    // Call the method to fetch the list of patient IDs in initState
    fetchAssignedPatients();
  }

  // Method to fetch assigned patients
  void fetchAssignedPatients() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    String? currentUserName = currentUser.displayName;
    print("Current user name: $currentUserName");

    // Fetch appointments where doctor_name is equal to the current user's name
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where("doctor_name", isEqualTo: 'Dr. brian')
        .get();

    print("Number of documents returned: ${querySnapshot.docs.length}");

    // Extract the list of patient IDs from the query snapshot
    List<String> ids = querySnapshot.docs.map((doc) => doc['patient_id'] as String).toList();

    setState(() {
      // Update the patientIds list
      patientIds = ids;
      // Update the selectedPatientId with the first patient ID if available
      if (patientIds.isNotEmpty) {
        selectedPatientId = patientIds.first;
      }
    });

    // Debug print to check patient IDs
    print("Patient IDs: $patientIds");
  }


  Widget _buildAppointmentsList(String status, String currentuserdisplayname) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where("doctor_name", isEqualTo: currentuserdisplayname)
          .orderBy("date", descending: true)
          .where('status', isEqualTo: status)
          .limit(5)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final appointments = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final appointment = Appointment.fromMap(data);
          appointment.documentId = doc.id;
          return appointment;
        }).toList();

        if (appointments.isEmpty) {
          return Center(
            child: Text('No appointments found.'),
          );
        }

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (BuildContext context, int index) {
            final appointment = appointments[index];
            return ListTile(
              title: Text(appointment.patientName),
              subtitle: Text(
                  '${appointment.doctorName}, ${appointment.date}, ${appointment.time}'),
              trailing: appointment.status == 'booked'
                  ? appointment.type == '1'
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 4,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Open phone app with the number "000000000"
                      launch("tel://7358518218");
                    },
                    child: Text('Call'),
                  ),
                ],
              )
                  : ElevatedButton(
                onPressed: () async {
                  await Database().cancelAppointmentCollection(
                      appointment.documentId);
                  await Database().cancelAppointmentRealtime(
                      appointment.doctorId,
                      appointment.date,
                      appointment.appointmentId);
                },
                child: Text('Cancel'),
              )
                  : null,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: UserProfile.getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          String? currentuserdisplayname = snapshot.data?.name;
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: Colors.grey[200],
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                centerTitle: true,
                elevation: 3,
                backgroundColor: Colors.grey[200],
                title: Text('Dashboard'),
                iconTheme: IconThemeData(color: Colors.black),
              ),
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                top: 5,
                                bottom: 5,
                              ),
                              child: Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                shadowColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Assigned Patients Namelist",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      DropdownButton<String>(
                                        value: selectedPatientId,
                                        items: patientIds.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedPatientId = value!;
                                          });
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => EmotionChart(selectedPatientId: selectedPatientId),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 30),
                                          backgroundColor: Colors.purple,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                        ),
                                        child: Text(
                                          "View Patient's Results",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      TabBar(
                        labelColor: Colors.black,
                        tabs: [
                          Tab(text: 'Upcoming'),
                          Tab(text: 'Completed'),
                          Tab(text: 'Canceled'),
                        ],
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildAppointmentsList('booked', currentuserdisplayname ?? "Unknown"),
                            _buildAppointmentsList('completed', currentuserdisplayname ?? "Unknown"),
                            _buildAppointmentsList('cancelled', currentuserdisplayname ?? "Unknown"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

