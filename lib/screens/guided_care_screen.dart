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

class GuidedCareScreen extends StatefulWidget {
  const GuidedCareScreen({super.key});

  @override
  State<GuidedCareScreen> createState() => _GuidedCareScreenState();
}

class _GuidedCareScreenState extends State<GuidedCareScreen> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildAppointmentsList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where("patient_id", isEqualTo: Auth().currentUser!.email)
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
              title: Text(appointment.doctorName),
              subtitle: Text(
                  '${appointment.patientName}, ${appointment.date}, ${appointment.time}'),
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
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext builderContext) {
                            return AlertDialog(
                              title: const Text('Cancel Appointment'),
                              content:
                              const Text('Confirm Cancellation.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Go Back'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await Database()
                                        .cancelAppointmentCollection(
                                        appointment.documentId);
                                    await Database()
                                        .cancelAppointmentRealtime(
                                        appointment.doctorId,
                                        appointment.date,
                                        appointment
                                            .appointmentId);
                                  },
                                  child: Text('Cancel Appointment'),
                                ),
                              ],
                            );
                          });
                    },
                    child: Text('Cancel'),
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
        backgroundColor: ConstantColors.secondaryBackgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          elevation: 3,
          backgroundColor: ConstantColors.secondaryBackgroundColor,
          title: Text(
            'Guided Care',
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                /* Guided care container */
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Guided Care",
                            style: GoogleFonts.rubik(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Book an Appointment",
                                        style: GoogleFonts.rubik(
                                          color: ConstantColors
                                              .primaryBackgroundColor,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Let's find your doctor.",
                                        style: GoogleFonts.rubik(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const AppointmentScreen(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30),
                                          backgroundColor: ConstantColors
                                              .primaryBackgroundColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(50),
                                          ),
                                        ),
                                        child: Text(
                                          "SCHEDULE",
                                          style: GoogleFonts.rubik(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Image.asset('assets/doctor.png'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TabBar(
                  labelColor: Colors.black,
                  tabs: [
                    Tab(
                      text: 'Upcoming',
                    ),
                    Tab(
                      text: 'Completed',
                    ),
                    Tab(
                      text: 'Canceled',
                    )
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

