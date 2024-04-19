import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solwoe/colors.dart';
import 'package:http/http.dart' as http;
import 'package:solwoe/database.dart';
import 'package:solwoe/model/user.dart';
import 'package:solwoe/services/notification_service.dart';

class PaymentScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> doctor;
  final UserProfile? userProfile;
  final String doctorId;
  final String patientId;
  final String date;
  final String slot;
  final String type;
  QueryDocumentSnapshot<Map<String, dynamic>>? assessmentDetails;
  PaymentScreen({
    super.key,
    required this.doctor,
    required this.userProfile,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.slot,
    required this.type,
    this.assessmentDetails,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? paymentIntentData;
  bool _isMakingPayment = false;
  late double totalAmount;
  late double tax;

  @override
  void initState() {
    super.initState();

    setState(() {
      tax = double.parse(widget.doctor['fee']) * 0.07;
      totalAmount = double.parse(widget.doctor['fee']) + tax;
    });
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
          'Billing Details',
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
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
                    const SizedBox(height: 8),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            color: Colors.white,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 12.0, right: 12.0, top: 20.0, bottom: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      widget.type == '0'
                          ? Icon(
                        Icons.person_outline,
                        color: Colors.grey,
                      )
                          : Icon(
                        Icons.videocam_outlined,
                        color: Colors.grey,
                      ),
                      widget.type == '0'
                          ? Text(
                        'In-Person Consultation Time',
                        style: GoogleFonts.quicksand(fontSize: 14),
                      )
                          : Text(
                        'Video Consultation Time',
                        style: GoogleFonts.quicksand(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        '${DateFormat('EEE, dd MMM').format(DateFormat('yyyy-MM-dd').parse(widget.date))} ${DateFormat('hh:mm a').format(DateFormat('HH:mm').parse(widget.slot))}',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bill Details',
                    style: GoogleFonts.quicksand(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Consultation Fees'),
                      Text(
                          '\u{20B9} ${double.parse(widget.doctor['fee']).toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Service Fee & Tax'),
                      Text('\u{20B9} ${tax.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                    child: Divider(
                      thickness: 2,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '\u{20B9} ${totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: _isMakingPayment
                ? null
                : () async {
              await makePayment();
              setState(() {
                onTap:
                null;
              });
            },
            child: Center(
              child: Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                  color: ConstantColors.primaryBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'PAY',
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      setState(() {
        _isMakingPayment = true;
      });
      paymentIntentData =
      await createPaymentIntent(totalAmount.toString(), 'INR');
      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentData!['client_secret'],
            customerId: paymentIntentData!['customer'],
            style: ThemeMode.light,
            merchantDisplayName: 'SOLWOE',
          ),
        );
      }

      displayPaymentSheet();
    } catch (e) {
      log('exception ${e.toString()}');
    } finally {
      setState(() {
        _isMakingPayment = false;
      });
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }).then((value) async {
        await NotificationService.showNotification(
            title: 'Solwoe',
            body:
            'Payment Successful.\nAmount Paid: \u{20B9} ${totalAmount.toStringAsFixed(2)}');
        await NotificationService.showNotification(
            title: 'Solwoe',
            body:
            'Appointment Booked Successfully.\nAppointment Date: ${widget.date} | Time:${widget.slot}')
            .then((value) async {
          String appointmenId = await Database().addAppointmentRealtime(
              widget.doctorId, widget.patientId, widget.date, widget.slot);
          if (widget.assessmentDetails != null) {
            final assessmentDetail = widget.assessmentDetails!;
            List<String> dobParts = widget.userProfile!.dateOfBirth.split('/');
            DateTime birthday = DateTime(int.parse(dobParts[2]),
                int.parse(dobParts[1]), int.parse(dobParts[0]));
            final currentDate = DateTime.now();
            int age = currentDate.year - birthday.year;
            if (currentDate.month < birthday.month ||
                (currentDate.month == birthday.month &&
                    currentDate.day < birthday.day)) {
              age--;
            }
            await Database().bookAppointmentCollection(
              doctorName:
              '${widget.doctor['salutation']} ${widget.doctor['name']}',
              doctorId: widget.doctorId,
              patientName: widget.userProfile!.name,
              patientId: widget.patientId,
              patientAge: age.toString(),
              patientGender: widget.userProfile!.gender,
              date: widget.date,
              time: widget.slot,
              appointmentId: appointmenId,
              type: widget.type,
              assessment: {
                'answers': assessmentDetail['answers'],
                'date': assessmentDetail['date'],
                'result': assessmentDetail['result'],
                'suggestion': assessmentDetail['suggestion'],
                'time': assessmentDetail['time'],
                'total_score': assessmentDetail['total_score'],
              },
            );
          } else {
            List<String> dobParts = widget.userProfile!.dateOfBirth.split('/');
            DateTime birthday = DateTime(int.parse(dobParts[2]),
                int.parse(dobParts[1]), int.parse(dobParts[0]));
            final currentDate = DateTime.now();
            int age = currentDate.year - birthday.year;
            if (currentDate.month < birthday.month ||
                (currentDate.month == birthday.month &&
                    currentDate.day < birthday.day)) {
              age--;
            }
            await Database().bookAppointmentCollection(
              doctorName:
              '${widget.doctor['salutation']} ${widget.doctor['name']}',
              doctorId: widget.doctorId,
              patientName: widget.userProfile!.name,
              patientId: widget.patientId,
              patientAge: age.toString(),
              patientGender: widget.userProfile!.gender,
              date: widget.date,
              time: widget.slot,
              appointmentId: appointmenId,
              type: widget.type,
            );
          }
        }).then((value) async {
          await NotificationService.showNotification(
            title: 'Solwoe',
            body: 'You have an appointment today at ${widget.slot}',
            scheduled: true,
            date: DateTime.parse('${widget.date} ${widget.slot}'),
          );
        });
      });
    } catch (e) {
      log('payment failed');
      log(e.toString());
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
            'Bearer YOUR_SK_API_KEY',
            'Content-Type': 'application/x-www-form-urlencoded',
          });
      return jsonDecode(response.body);
    } catch (e) {
      log('exception' + e.toString());
    }
  }

  calculateAmount(String amount) {
    final price = (double.parse(amount)).toInt() * 100;
    return price.toString();
  }
}