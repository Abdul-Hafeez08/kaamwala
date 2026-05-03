import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String profileImage;
  final String address;
  final String location;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage = '',
    this.address = '',
    this.location = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'address': address,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'user',
      profileImage: map['profileImage'] ?? '',
      address: map['address'] ?? '',
      location: map['location'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profileImage,
    String? address,
    String? location,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class WorkerModel {
  final String workerId;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String serviceType;
  final String experience;
  final String skills;
  final String location;
  final bool availability;
  final double rating;
  final String approvalStatus;
  final String nic;
  final String pricingType; // 'hourly' or 'fixed'
  final double hourlyRate;
  final DateTime createdAt;

  WorkerModel({
    required this.workerId,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage = '',
    this.serviceType = '',
    this.experience = '',
    this.skills = '',
    this.location = '',
    this.availability = true,
    this.rating = 0.0,
    this.approvalStatus = 'pending',
    this.nic = '',
    this.pricingType = 'fixed',
    this.hourlyRate = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'workerId': workerId,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'serviceType': serviceType,
      'experience': experience,
      'skills': skills,
      'location': location,
      'availability': availability,
      'rating': rating,
      'approvalStatus': approvalStatus,
      'nic': nic,
      'pricingType': pricingType,
      'hourlyRate': hourlyRate,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory WorkerModel.fromMap(Map<String, dynamic> map) {
    return WorkerModel(
      workerId: map['workerId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'] ?? '',
      serviceType: map['serviceType'] ?? '',
      experience: map['experience'] ?? '',
      skills: map['skills'] ?? '',
      location: map['location'] ?? '',
      availability: map['availability'] ?? true,
      rating: (map['rating'] ?? 0.0).toDouble(),
      approvalStatus: map['approvalStatus'] ?? 'pending',
      nic: map['nic'] ?? '',
      pricingType: map['pricingType'] ?? 'fixed',
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  WorkerModel copyWith({
    String? workerId,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? serviceType,
    String? experience,
    String? skills,
    String? location,
    bool? availability,
    double? rating,
    String? approvalStatus,
    String? nic,
    String? pricingType,
    double? hourlyRate,
    DateTime? createdAt,
  }) {
    return WorkerModel(
      workerId: workerId ?? this.workerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      serviceType: serviceType ?? this.serviceType,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      availability: availability ?? this.availability,
      rating: rating ?? this.rating,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      nic: nic ?? this.nic,
      pricingType: pricingType ?? this.pricingType,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
