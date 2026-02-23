import 'package:cloud_firestore/cloud_firestore.dart';

class CoupleModel {
  final String id;
  final String user1Uid;
  final String user2Uid;
  final DateTime? startDate;

  CoupleModel({
    required this.id,
    required this.user1Uid,
    required this.user2Uid,
    this.startDate,
  });

  factory CoupleModel.fromJson(Map<String, dynamic> json) {
    return CoupleModel(
      id: json['id'] as String,
      user1Uid: json['user1Uid'] as String,
      user2Uid: json['user2Uid'] as String,
      startDate: (json['startDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1Uid': user1Uid,
      'user2Uid': user2Uid,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
    };
  }
}
