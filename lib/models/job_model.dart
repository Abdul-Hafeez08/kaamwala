import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String jobId;
  final String userId;
  final String workerId;
  final String serviceType;
  final String description;
  final String status;
  final String location;
  final double price;
  final String address;
  final String userName;
  final String userPhone;
  final String workerName;
  final String workerImage;
  final DateTime scheduledDate;
  final String scheduledTime;
  final double userRating;
  final String userReview;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  JobModel({
    required this.jobId,
    required this.userId,
    required this.workerId,
    required this.serviceType,
    this.description = '',
    this.status = 'pending',
    this.location = '',
    this.price = 0.0,
    this.address = '',
    this.userName = '',
    this.userPhone = '',
    this.workerName = '',
    this.workerImage = '',
    DateTime? scheduledDate,
    this.scheduledTime = '',
    this.userRating = 0.0,
    this.userReview = '',
    this.startedAt,
    this.completedAt,
    DateTime? createdAt,
  })  : scheduledDate = scheduledDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'userId': userId,
      'workerId': workerId,
      'serviceType': serviceType,
      'description': description,
      'status': status,
      'location': location,
      'price': price,
      'address': address,
      'userName': userName,
      'userPhone': userPhone,
      'workerName': workerName,
      'workerImage': workerImage,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'scheduledTime': scheduledTime,
      'userRating': userRating,
      'userReview': userReview,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      jobId: map['jobId'] ?? '',
      userId: map['userId'] ?? '',
      workerId: map['workerId'] ?? '',
      serviceType: map['serviceType'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      location: map['location'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      workerName: map['workerName'] ?? '',
      workerImage: map['workerImage'] ?? '',
      scheduledDate: (map['scheduledDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledTime: map['scheduledTime'] ?? '',
      userRating: (map['userRating'] ?? 0.0).toDouble(),
      userReview: map['userReview'] ?? '',
      startedAt: (map['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  JobModel copyWith({
    String? jobId,
    String? userId,
    String? workerId,
    String? serviceType,
    String? description,
    String? status,
    String? location,
    double? price,
    String? address,
    String? userName,
    String? userPhone,
    String? workerName,
    String? workerImage,
    DateTime? scheduledDate,
    String? scheduledTime,
    double? userRating,
    String? userReview,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return JobModel(
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      workerId: workerId ?? this.workerId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      status: status ?? this.status,
      location: location ?? this.location,
      price: price ?? this.price,
      address: address ?? this.address,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      workerName: workerName ?? this.workerName,
      workerImage: workerImage ?? this.workerImage,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      userRating: userRating ?? this.userRating,
      userReview: userReview ?? this.userReview,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
