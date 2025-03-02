import 'dart:convert';

import 'package:uuid/uuid.dart';

class ReservationFields {
  static const String id = 'reservation_id';
  static const String userId = 'user_id';
  static const String establishmentId = 'establishment_id';
  static const String slotId = 'slot_id';
  static const String vehicleId = 'vehicle_id';
  static const String status = 'status';
  static const String startTime = 'start_time';
  static const String endTime = 'end_time';
  static const String createdAt = 'created_at';
}

class Reservation {
  final String? id;
  final String userId;
  final String establishmentId;
  final String slotId;
  final String vehicleId;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;

  Reservation({
    this.id,
    required this.userId,
    required this.establishmentId,
    required this.slotId,
    required this.vehicleId,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map[ReservationFields.id] as String? ?? '',
      userId: map[ReservationFields.userId] as String? ?? '',
      establishmentId: map[ReservationFields.establishmentId] as String? ?? '',
      slotId: map[ReservationFields.slotId] as String? ?? '',
      vehicleId: map[ReservationFields.vehicleId] as String? ?? '',
      status: map[ReservationFields.status] as String? ?? '',
      startTime: DateTime.tryParse(map[ReservationFields.startTime] as String? ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map[ReservationFields.endTime] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(map[ReservationFields.createdAt] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ReservationFields.id: id,
      ReservationFields.userId: userId,
      ReservationFields.establishmentId: establishmentId,
      ReservationFields.slotId: slotId,
      ReservationFields.vehicleId: vehicleId,
      ReservationFields.status: status,
      ReservationFields.startTime: startTime.toIso8601String(),
      ReservationFields.endTime: endTime.toIso8601String(),
      ReservationFields.createdAt: createdAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());
}
