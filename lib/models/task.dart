import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String? assignedTo;
  final String? assignedToName;
  final DateTime? dueDate;
  final bool isCompleted;
  final String createdBy;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.assignedTo,
    this.assignedToName,
    this.dueDate,
    required this.isCompleted,
    required this.createdBy,
    required this.createdAt,
  });

  factory Task.fromFirestore(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      title: data['title'] as String? ?? '',
      assignedTo: data['assignedTo'] as String?,
      assignedToName: data['assignedToName'] as String?,
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
