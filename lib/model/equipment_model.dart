import 'package:uuid/uuid.dart';

class Equipment {
  final String id;
  final String name;
  final String brand;
  final String model;
  final DateTime acquisitionDate;
  final int expectedLifespan;

  Equipment({
    required String? id,
    required this.name,
    required this.brand,
    required this.model,
    required this.acquisitionDate,
    required this.expectedLifespan,
  }) : this.id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'acquisitionDate': acquisitionDate.toIso8601String(),
      'expectedLifespan': expectedLifespan,
    };
  }

  static Equipment fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      model: map['model'],
      acquisitionDate: DateTime.parse(map['acquisitionDate']),
      expectedLifespan: map['expectedLifespan'],
    );
  }
}