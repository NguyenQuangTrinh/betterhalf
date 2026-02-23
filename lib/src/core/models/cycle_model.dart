import 'package:cloud_firestore/cloud_firestore.dart';

class CycleModel {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;

  CycleModel({
    required this.id,
    required this.startDate,
    this.endDate,
    this.notes,
  });

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    return CycleModel(
      id: json['id'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp?)?.toDate(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'notes': notes,
    };
  }
}
