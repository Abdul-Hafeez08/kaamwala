import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;

  const ServiceCategory({
    this.id = '',
    required this.name,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
    };
  }

  factory ServiceCategory.fromMap(Map<String, dynamic> map, String docId) {
    return ServiceCategory(
      id: docId,
      name: map['name'] ?? '',
      icon: IconData(
        map['iconCodePoint'] ?? Icons.home_repair_service.codePoint,
        fontFamily: map['iconFontFamily'] ?? 'MaterialIcons',
      ),
    );
  }
}

const List<ServiceCategory> allServiceCategories = [
  ServiceCategory(name: 'Electrician', icon: Icons.electrical_services),
  ServiceCategory(name: 'Plumber', icon: Icons.plumbing),
  ServiceCategory(name: 'AC Technician', icon: Icons.ac_unit),
  ServiceCategory(name: 'Solar Panel Service', icon: Icons.solar_power),
  ServiceCategory(name: 'Home Tutor', icon: Icons.school),
  ServiceCategory(name: 'Car Wash at Home', icon: Icons.local_car_wash),
  ServiceCategory(name: 'Painter', icon: Icons.format_paint),
  ServiceCategory(name: 'CCTV Service', icon: Icons.videocam),
  ServiceCategory(name: 'Event Decoration', icon: Icons.celebration),
  ServiceCategory(name: 'Beauty Salon / Haircut', icon: Icons.content_cut),
  ServiceCategory(name: 'House Cleaning', icon: Icons.cleaning_services),
  ServiceCategory(name: 'Maid Service', icon: Icons.home),
  ServiceCategory(name: 'Carpenter', icon: Icons.carpenter),
  ServiceCategory(name: 'Laundry & Ironing', icon: Icons.local_laundry_service),
];

List<String> get serviceCategoryNames =>
    allServiceCategories.map((category) => category.name).toList();

ServiceCategory? findServiceByName(String name) {
  try {
    return allServiceCategories.firstWhere(
      (category) => category.name == name,
    );
  } catch (_) {
    return null;
  }
}
