import 'dart:convert';

import 'package:eseepark/models/payment_model.dart';
import 'package:uuid/uuid.dart';

class ReservationFields {
  static const String id = 'reservation_id';
  static const String userId = 'user_id';
  static const String establishmentId = 'establishment_id';
  static const String slotId = 'slot_id';
  static const String vehicleId = 'vehicle_id';
  static const String reservationCode = 'reservation_code';
  static const String status = 'status';
  static const String startTime = 'start_time';
  static const String endTime = 'end_time';
  static const String totalFee = 'total_fee';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class Reservation {
  final String? id;
  final String userId;
  final String establishmentId;
  final String slotId;
  final String? vehicleId;
  final String? reservationCode;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final double totalFee;
  final DateTime createdAt;
  final DateTime updatedAt;

  final PaymentModel? payment;

  Reservation({
    this.id,
    required this.userId,
    required this.establishmentId,
    required this.slotId,
    this.vehicleId,
    this.reservationCode,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.totalFee,
    required this.createdAt,
    required this.updatedAt,
    this.payment
  });

  Reservation copyWith({
    String? id,
    String? userId,
    String? establishmentId,
    String? slotId,
    String? vehicleId,
    String? reservationCode,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    double? totalFee,
    DateTime? createdAt,
    DateTime? updatedAt,
    PaymentModel? payment
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      establishmentId: establishmentId ?? this.establishmentId,
      slotId: slotId ?? this.slotId,
      vehicleId: vehicleId ?? this.vehicleId,
      reservationCode: reservationCode ?? this.reservationCode,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalFee: totalFee ?? this.totalFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      payment: payment ?? this.payment
    );
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map[ReservationFields.id] as String? ?? '',
      userId: map[ReservationFields.userId] as String? ?? '',
      establishmentId: map[ReservationFields.establishmentId] as String? ?? '',
      slotId: map[ReservationFields.slotId] as String? ?? '',
      vehicleId: map[ReservationFields.vehicleId] as String? ?? '',
      reservationCode: map[ReservationFields.reservationCode] as String? ?? '',
      status: map[ReservationFields.status] as String? ?? '',
      startTime: DateTime.tryParse(map[ReservationFields.startTime] as String? ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map[ReservationFields.endTime] as String? ?? '') ?? DateTime.now(),
      totalFee: map[ReservationFields.totalFee] != null ? (map[ReservationFields.totalFee] as num).toDouble() : 0.0,
      createdAt: DateTime.tryParse(map[ReservationFields.createdAt] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map[ReservationFields.updatedAt] as String? ?? '') ?? DateTime.now(),
      payment: map['payment'] != null && map['payment'] is Map<String, dynamic>
          ? PaymentModel.fromMap(map['payment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap({bool withPayment = false}) {
    if(withPayment) {
      return {
        ReservationFields.id: id,
        ReservationFields.userId: userId,
        ReservationFields.establishmentId: establishmentId,
        ReservationFields.slotId: slotId,
        ReservationFields.vehicleId: vehicleId,
        ReservationFields.reservationCode: reservationCode,
        ReservationFields.status: status,
        ReservationFields.startTime: startTime.toIso8601String(),
        ReservationFields.endTime: endTime.toIso8601String(),
        ReservationFields.totalFee: totalFee,
        ReservationFields.createdAt: createdAt.toIso8601String(),
        ReservationFields.updatedAt: updatedAt.toIso8601String(),
        'payment': payment?.toMap() ?? {}
      };
    } else {
      return {
        ReservationFields.id: id,
        ReservationFields.userId: userId,
        ReservationFields.establishmentId: establishmentId,
        ReservationFields.slotId: slotId,
        ReservationFields.vehicleId: vehicleId,
        ReservationFields.reservationCode: reservationCode,
        ReservationFields.status: status,
        ReservationFields.startTime: startTime.toIso8601String(),
        ReservationFields.endTime: endTime.toIso8601String(),
        ReservationFields.totalFee: totalFee,
        ReservationFields.createdAt: createdAt.toIso8601String(),
        ReservationFields.updatedAt: updatedAt.toIso8601String(),
      };
    }
  }

  String toJson() => json.encode(toMap());
}
