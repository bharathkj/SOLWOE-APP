import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/database.dart';
import 'package:solwoe/model/user.dart';
import 'package:solwoe/screens/doctor_details_screen.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  UserProfile? _userProfile;
  int numDoctorsToDisplay = 4;
  String? searchName = '';
  String? searchLocation = '';
  String _selectedDoctor = '';

  DateTime? _date;
  TimeOfDay? _time;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _asyncMethod();
  }

  _asyncMethod() async {
    _userProfile = await UserProfile.getUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 3,
        backgroundColor: ConstantColors.secondaryBackgroundColor,
        title: Text(
          'Book Appointment',
          style: GoogleFonts.sourceSerifPro(
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchName = value;
                  });
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search by doctor name',
                  suffixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: searchName != null && searchName!.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection('doctors')
                        .where('onboarding',isEqualTo:true)
                        .where('name',
                            isGreaterThanOrEqualTo: searchName!.toLowerCase())
                        .where('name',
                            isLessThan: searchName!.toLowerCase() + 'z')
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('doctors')
                        .where('onboarding',isEqualTo:true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final allDoctors = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: allDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = allDoctors[index];
                      return Card(
                        elevation: 8,
                        shadowColor: Colors.grey,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  doctor['gender'] == 'male'
                                      ? 'assets/doctor.png'
                                      : 'assets/femaleDoctor.png',
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${doctor['salutation']} ${doctor['name'].toString().substring(0, 1).toUpperCase()}${doctor['name'].toString().substring(1)}',
                                    style: GoogleFonts.quicksand(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${doctor['speciality'].toString().substring(0, 1).toUpperCase()}${doctor['speciality'].toString().substring(1)}',
                                    style: GoogleFonts.quicksand(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  Text(
                                    '${doctor['category'].toString().substring(0, 1).toUpperCase()}${doctor['category'].toString().substring(1)}',
                                    style: GoogleFonts.quicksand(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  const SizedBox(height: 8),
                                  if (doctor['consultation'] == 0)
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => DoctorDetailsScreen(
                                              doctor: doctor,
                                              userProfile: _userProfile,
                                              type: 'person',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('In-Person Visit'),
                                    )
                                  else if (doctor['consultation'] == 1)
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => DoctorDetailsScreen(
                                              doctor: doctor,
                                              userProfile: _userProfile,
                                              type: 'video',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Video Consultation'),
                                    )
                                  else
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DoctorDetailsScreen(
                                                  doctor: doctor,
                                                  userProfile: _userProfile,
                                                  type: 'video',
                                                ),
                                              ),
                                            );
                                          },
                                          child:
                                              const Text('Video Consultation'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DoctorDetailsScreen(
                                                  doctor: doctor,
                                                  userProfile: _userProfile,
                                                  type: 'person',
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('In-Person Visit'),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
