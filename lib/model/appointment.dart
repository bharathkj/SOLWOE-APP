class Appointment {
  late final String documentId;
  final String doctorName;
  final String doctorId;
  final String patientName;
  final String patientId;
  final String date;
  final String time;
  final String status;
  String appointmentId;
  final String type;

  Appointment({
    required this.doctorName,
    required this.doctorId,
    required this.patientName,
    required this.patientId,
    required this.date,
    required this.time,
    required this.status,
    this.appointmentId='',
    required this.type,
  });

  factory Appointment.fromMap(Map<String, dynamic> json) {
    return Appointment(
      doctorName: json['doctor_name'],
      doctorId: json['doctor_id'],
      patientName: json['patient_name'],
      patientId: json['patient_id'],
      date: json['date'],
      time: json['time'],
      status: json['status'],
      type: json['type'],
      appointmentId: json['appointmentId'],
    );
  }

}
