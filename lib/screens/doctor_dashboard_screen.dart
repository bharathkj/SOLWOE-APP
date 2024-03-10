import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solwoe/auth.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/database.dart';
import 'package:solwoe/model/appointment.dart';
import 'package:solwoe/screens/appointment_screen.dart';
import 'package:intl/intl.dart';
import 'package:solwoe/screens/video_consultation_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'emotion_chart.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreen();
}

class _DoctorDashboardScreen extends State<DoctorDashboardScreen> {
  String selectedEmail = "coomestofcoomer@gmail.com";
  @override
  void initState() {
    super.initState();
  }

  Widget _buildAppointmentsList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where("doctor_name", isEqualTo: 'Dr. brian')
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
                  '${appointment.doctorName}, ${appointment.date}, ${appointment
                      .time}'),
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
                                  value: selectedEmail,
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: "coomestofcoomer@gmail.com",
                                      child: Text("coomestofcoomer@gmail.com"),
                                    ),
                                    // Add more email options as needed
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedEmail = value!;
                                    });
                                  },
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => EmotionChart(),
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
                      _buildAppointmentsList('booked'),
                      _buildAppointmentsList('completed'),
                      _buildAppointmentsList('cancelled'),
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
}

