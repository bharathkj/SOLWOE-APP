import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/model/slot.dart';
import 'package:solwoe/model/user.dart';
import 'package:solwoe/screens/payment_screen.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> doctor;
  UserProfile? userProfile;
  String? type;
  DoctorDetailsScreen(
      {super.key, required this.doctor, this.userProfile, this.type});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  DateTime? _selectedDate;
  late DatabaseReference _dbRef;
  late List<Slot> slots = [];
  late bool _isWeekend;
  bool _isSlotSelected = false;
  int _consultation = -1;
  bool isAssessmentTaken = false;
  int shareResult = -1;
  late Stream<DatabaseEvent> stream;
  late QuerySnapshot<Map<String, dynamic>> querySnapshot;

  @override
  void initState() {
    super.initState();
    if (widget.userProfile == null) {
      _asyncMethod();
    }
    _dbRef = FirebaseDatabase.instance.ref();
    setState(() {
      if (widget.type != null) {
        _consultation = widget.type == 'person' ? 0 : 1;
      }
    });
    _assessmentStatus();
  }

  _asyncMethod() async {
    widget.userProfile = await UserProfile.getUserProfile();
  }

  _assessmentStatus() async {
    querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userProfile!.email)
        .collection('assessment')
        .orderBy('date', descending: true)
        .orderBy('time', descending: true)
        .limit(1)
        .get();
    setState(() {
      if (querySnapshot.docs.isNotEmpty) {
        isAssessmentTaken = true;
      } else {
        isAssessmentTaken = false;
      }
    });
  }

  Future<void> generateSlots() async {
    Map<String, dynamic> slotData = widget.doctor['slots'];

    String startTime = _isWeekend == true
        ? slotData['weekend']['start time']
        : slotData['weekday']['start time'];
    String endTime = _isWeekend == true
        ? slotData['weekend']['end time']
        : slotData['weekday']['end time'];
    DateTime start = DateTime.parse(
        '${DateFormat('yyyy-MM-dd').format(_selectedDate!)} $startTime:00');
    DateTime end = DateTime.parse(
        '${DateFormat('yyyy-MM-dd').format(_selectedDate!)} $endTime:00');
    Duration interval = Duration(hours: 1);
    DateTime current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      String time = '${current.hour.toString().padLeft(2, '0')}:'
          '${current.minute.toString().padLeft(2, '0')}';
      slots.add(Slot(time: time));
      current = current.add(interval);
    }
    String lunchStartTime = slotData['lunch']['start time'];
    String lunchEndTime = slotData['lunch']['end time'];
    for (int i = 0; i < slots.length; i++) {
      log(slots[i].time);
      if (slots[i].time == lunchStartTime) {
        slots[i].isLunch = true;
        for (int j = i + 1;
            j < slots.length && slots[j].time != lunchEndTime;
            j++) {
          slots[j].isLunch = true;
        }
        break;
      }
    }
  }

  void _selectSlot(int index) {
    setState(() {
      for (int i = 0; i < slots.length; i++) {
        slots[i].selected = (i == index && !slots[i].selected);
      }
      _isSlotSelected = slots.any((slot) => slot.selected);
    });
  }

  Future<bool> checkWeekend(DateTime? selectedDate) async {
    if (selectedDate?.weekday == DateTime.saturday ||
        selectedDate?.weekday == DateTime.sunday) {
      log('true');
      return true;
    }
    return false;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      slots.clear();
      _selectedDate = picked;
      _isSlotSelected = false;

      _isWeekend = await checkWeekend(_selectedDate);
      await generateSlots();
      setState(() {});
    }
  }

  Widget _buildGridView() {
    String date = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    List<Slot> filteredSlots = slots
        .where((slot) =>
            DateTime.parse('$date ${slot.time}:00').isAfter(DateTime.now()))
        .toList();
    if (filteredSlots.isEmpty) {
      return Text('No Slots');
    }
    return GridView.count(
      childAspectRatio: 2,
      crossAxisCount: 3,
      shrinkWrap: true,
      children: filteredSlots.map((Slot slot) {
        Color color;
        String label;
        if (slot.isLunch) {
          color = Colors.yellow;
          label = 'Lunch';
        } else if (slot.isAvailable == false && slot.isBooked == false) {
          color = Colors.grey;
          label = 'Unavailable';
        } else if (slot.isBooked) {
          color = Colors.red;
          label = 'Booked';
        } else {
          color = Colors.green;
          label = 'Available';
        }
        return GestureDetector(
          onTap: slot.isLunch
              ? null
              : !slot.isAvailable || slot.isBooked
                  ? null
                  : () {
                      _selectSlot(slots.indexOf(slot));
                    },
          child: Container(
            padding: EdgeInsets.all(4.0),
            margin: EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.0),
              border: slot.selected
                  ? Border.all(
                      color: ConstantColors.selectedButtonColor, width: 5.0)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('hh:mm a')
                      .format(DateTime.parse('1970-01-01 ${slot.time}:00')),
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.secondaryBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 3,
        backgroundColor: ConstantColors.secondaryBackgroundColor,
        title: Text(
          'Doctor Details',
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        widget.doctor['gender'] == 'male'
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
                          '${widget.doctor['salutation']} ${widget.doctor['name'].toString().substring(0, 1).toUpperCase()}${widget.doctor['name'].toString().substring(1)}',
                          style: GoogleFonts.quicksand(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.doctor['speciality'].toString().substring(0, 1).toUpperCase()}${widget.doctor['speciality'].toString().substring(1)}',
                          style: GoogleFonts.quicksand(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        ),
                        Text(
                          '${widget.doctor['category'].toString().substring(0, 1).toUpperCase()}${widget.doctor['category'].toString().substring(1)}',
                          style: GoogleFonts.quicksand(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '~ \u{20B9} ${widget.doctor['fee']} ',
                              style: GoogleFonts.quicksand(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Consultation Fees',
                              style: GoogleFonts.quicksand(
                                  fontSize: 16, fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                color: Colors.white,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 12.0, top: 20.0, bottom: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Consultation'),
                      if (widget.doctor['consultation'] == 0)
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _consultation = 0;
                            });
                          },
                          child: Text(
                            "In-Person Visit",
                            style: TextStyle(
                              color: (_consultation == 0)
                                  ? Colors.green
                                  : Colors.black,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            side: BorderSide(
                                color: (_consultation == 0)
                                    ? Colors.green
                                    : Colors.black),
                          ),
                        )
                      else if (widget.doctor['consultation'] == 1)
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _consultation = 1;
                            });
                          },
                          child: Text(
                            "Video Consultation",
                            style: TextStyle(
                              color: (_consultation == 1)
                                  ? Colors.green
                                  : Colors.black,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            side: BorderSide(
                                color: (_consultation == 1)
                                    ? Colors.green
                                    : Colors.black),
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _consultation = 0;
                                });
                              },
                              child: Text(
                                "In-Person Visit",
                                style: TextStyle(
                                  color: (_consultation == 0)
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                side: BorderSide(
                                    color: (_consultation == 0)
                                        ? Colors.green
                                        : Colors.black),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _consultation = 1;
                                });
                              },
                              child: Text(
                                "Video Consultation",
                                style: TextStyle(
                                  color: (_consultation == 1)
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                side: BorderSide(
                                    color: (_consultation == 1)
                                        ? Colors.green
                                        : Colors.black),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: isAssessmentTaken,
                child: const SizedBox(
                  height: 8,
                ),
              ),
              Visibility(
                visible: isAssessmentTaken,
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, right: 12.0, top: 20.0, bottom: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Share Latest Assessment'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  shareResult = 0;
                                });
                              },
                              child: Text(
                                "Yes",
                                style: TextStyle(
                                  color: (shareResult == 0)
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                side: BorderSide(
                                    color: (shareResult == 0)
                                        ? Colors.green
                                        : Colors.black),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  shareResult = 1;
                                });
                              },
                              child: Text(
                                "No",
                                style: TextStyle(
                                  color: (shareResult == 1)
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                side: BorderSide(
                                    color: (shareResult == 1)
                                        ? Colors.green
                                        : Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _selectedDate == null
                            ? Text(
                                'Select a date',
                                style: GoogleFonts.rubik(
                                  fontSize: 18,
                                ),
                              )
                            : Text(
                                DateFormat('dd-MM-yyyy').format(_selectedDate!),
                                style: GoogleFonts.rubik(
                                  fontSize: 18,
                                ),
                              ),
                        Icon(
                          Icons.arrow_forward_ios,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              _selectedDate != null
                  ? StreamBuilder(
                      stream: _dbRef
                          .child('appointments')
                          .child(widget.doctor['phone'])
                          .child(
                              DateFormat('yyyy-MM-dd').format(_selectedDate!))
                          .onValue,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Text('Loading...');
                          default:
                            if (!snapshot.hasData) {
                              return Text('No data found.');
                            }
                            final Map<dynamic, dynamic>? data =
                                snapshot.data!.snapshot.value;
                            if (data != null) {
                              log('in');
                              for (int i = 0; i < slots.length; i++) {
                                String time = slots[i].time;

                                data.forEach((key, value) {
                                  if (value['slot'] == time) {
                                    slots[i].isAvailable = value['isAvailable'];
                                    log('unavailable');
                                  }
                                  if (value['slot'] == time &&
                                      value['isBooked'] == true) {
                                    slots[i].isBooked = true;
                                    log('booked');
                                  }
                                });
                              }
                            }
                            return _buildGridView();
                        }
                      },
                    )
                  : Center(
                      child: Text("Select a Date to pick a slot"),
                    ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: _isSlotSelected && _consultation != -1
                    ? () async {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext builderContext) {
                              return AlertDialog(
                                title: const Text('Confirm'),
                                content: const Text('Confirm Booking.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      Slot selectedSlot = slots
                                          .firstWhere((slot) => slot.selected);

                                      await _updateFirestore();

                                      /*Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => shareResult == 0
                                              ? PaymentScreen(
                                                  doctor: widget.doctor,
                                                  userProfile:
                                                      widget.userProfile,
                                                  doctorId:
                                                      widget.doctor['phone'],
                                                  patientId:
                                                      widget.userProfile!.email,
                                                  date: DateFormat('yyyy-MM-dd')
                                                      .format(_selectedDate!),
                                                  slot: selectedSlot.time,
                                                  type:
                                                      _consultation.toString(),
                                                  assessmentDetails:
                                                      querySnapshot.docs.first,
                                                )
                                              : PaymentScreen(
                                                  doctor: widget.doctor,
                                                  userProfile:
                                                      widget.userProfile,
                                                  doctorId:
                                                      widget.doctor['phone'],
                                                  patientId:
                                                      widget.userProfile!.email,
                                                  date: DateFormat('yyyy-MM-dd')
                                                      .format(_selectedDate!),
                                                  slot: selectedSlot.time,
                                                  type:
                                                      _consultation.toString(),
                                                ),
                                        ),
                                      );*/
                                    },
                                    child: Text('Pay & Confirm Appointment'),
                                  ),
                                ],
                              );
                            });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: ConstantColors.primaryBackgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Confirm Date & Time',
                    style: GoogleFonts.rubik(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateFirestore() async {
    Slot selectedSlot = slots.firstWhere((slot) => slot.selected);

    try {
      // Assuming 'appointments' is your Firestore collection
      await FirebaseFirestore.instance.collection('appointments').add({
        'doctor_name': '${widget.doctor['salutation']} ${widget.doctor['name']}',
        'doctor_id': widget.doctor['phone'],
        'patient_name': widget.userProfile!.name,
        'patient_id': widget.userProfile!.email,
        'patient_age': '69',
        'patient_gender': widget.userProfile!.gender,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'time': selectedSlot.time,
        'appointmentId': '539f9snme9',
        'type': _consultation.toString(),
        'status': 'booked',
        // Add other appointment details...
      });

      // You can also update the availability status in Firestore if needed
      // ...

      // Update your local UI state if necessary
      setState(() {
        // Update your local UI state here...
      });
    } catch (e) {
      // Handle errors
      print('Error updating Firestore: $e');
    }
  }

}


