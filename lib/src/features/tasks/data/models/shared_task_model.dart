import 'package:cloud_firestore/cloud_firestore.dart';

class SharedTask {
  final String id;
  final String title;
  final String? description;
  final String? priority;
  final String? assigneeId;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;

  SharedTask({
    required this.id,
    required this.title,
    this.description,
    this.assigneeId,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.priority = 'Trung bình',
  });

  factory SharedTask.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return SharedTask(
      id: id,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      assigneeId: map['assigneeId']?.toString(),
      isCompleted: map['isCompleted'] == true,
      createdAt: map['createdAt'] != null
          ? parseDate(map['createdAt'])
          : DateTime.now(),
      dueDate: map['dueDate'] != null ? parseDate(map['dueDate']) : null,
      priority: map['priority']?.toString() ?? 'Trung bình',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'assigneeId': assigneeId,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'priority': priority,
    };
  }

  SharedTask copyWith({
    String? title,
    String? description,
    String? assigneeId,
    bool? isCompleted,
    DateTime? dueDate,
    String? priority,
  }) {
    return SharedTask(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      assigneeId: assigneeId ?? this.assigneeId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
    );
  }
}
