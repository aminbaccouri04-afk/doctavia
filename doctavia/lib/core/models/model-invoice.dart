class InvoiceModel {
  final int id;
  final int appointmentId;
  final int patientProfileId;
  final int doctorId;
  final double amount;
  final String status;
  final DateTime? issuedAt;
  final DateTime? paidAt;

  InvoiceModel({
    required this.id,
    required this.appointmentId,
    required this.patientProfileId,
    required this.doctorId,
    required this.amount,
    required this.status,
    this.issuedAt,
    this.paidAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      appointmentId: json['appointmentId'] is int ? json['appointmentId'] : int.parse(json['appointmentId'].toString()),
      patientProfileId: json['patientProfileId'] is int ? json['patientProfileId'] : int.parse(json['patientProfileId'].toString()),
      doctorId: json['doctorId'] is int ? json['doctorId'] : int.parse(json['doctorId'].toString()),
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      issuedAt: json['issuedAt'] != null ? DateTime.parse(json['issuedAt'] as String) : null,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
    );
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
}
