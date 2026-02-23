import 'package:cloud_firestore/cloud_firestore.dart';

enum MemoryType { photo, checkin }

class MemoryModel {
  final String id;
  final MemoryType type;
  final String? imageUrl;
  final String? locationName;
  final double? lat;
  final double? lng;
  final DateTime timestamp;
  final String? note;

  MemoryModel({
    required this.id,
    required this.type,
    this.imageUrl,
    this.locationName,
    this.lat,
    this.lng,
    required this.timestamp,
    this.note,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      id: json['id'] as String,
      type: MemoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MemoryType.photo,
      ),
      imageUrl: json['imageUrl'] as String?,
      locationName: json['locationName'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'imageUrl': imageUrl,
      'locationName': locationName,
      'lat': lat,
      'lng': lng,
      'timestamp': Timestamp.fromDate(timestamp),
      'note': note,
    };
  }
}
