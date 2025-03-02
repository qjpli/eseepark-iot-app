import 'dart:convert';

class ParkingRateFields {
  static final String rateId = 'rate_id';
  static final String establishmentId = 'establishment_id';
  static final String rateType = 'rate_type';
  static final String flatRate = 'flat_rate';
  static final String baseRate = 'base_rate';
  static final String baseHours = 'base_hours';
  static final String extraHourlyRate = 'extra_hourly_rate';
  static final String reserveRatePerHour = 'reserve_rate';
  static final String maxDailyRate = 'max_daily_rate';
  static final String createdAt = 'created_at';
}

class ParkingRate {
  final String rateId;
  final String establishmentId;
  final String rateType;
  final double? flatRate;
  final double? baseRate;
  final int? baseHours;
  final double? extraHourlyRate;
  final double? reserveRate;
  final double? maxDailyRate;
  final DateTime createdAt;

  ParkingRate({
    required this.rateId,
    required this.establishmentId,
    required this.rateType,
    this.flatRate,
    this.baseRate,
    this.baseHours,
    this.extraHourlyRate,
    this.reserveRate,
    this.maxDailyRate,
    required this.createdAt,
  });

  factory ParkingRate.fromMap(Map<String, dynamic> map) {
    return ParkingRate(
      rateId: map[ParkingRateFields.rateId] as String? ?? '',
      establishmentId: map[ParkingRateFields.establishmentId] as String? ?? '',
      rateType: map[ParkingRateFields.rateType] as String? ?? '',
      flatRate: map[ParkingRateFields.flatRate] != null ? (map[ParkingRateFields.flatRate] as num).toDouble() : null,
      baseRate: map[ParkingRateFields.baseRate] != null ? (map[ParkingRateFields.baseRate] as num).toDouble() : null,
      baseHours: map[ParkingRateFields.baseHours] as int?, // Ensure it's nullable
      extraHourlyRate: map[ParkingRateFields.extraHourlyRate] != null ? (map[ParkingRateFields.extraHourlyRate] as num).toDouble() : null,
      reserveRate: map[ParkingRateFields.reserveRatePerHour] != null ? (map[ParkingRateFields.reserveRatePerHour] as num).toDouble() : null,
      maxDailyRate: map[ParkingRateFields.maxDailyRate] != null ? (map[ParkingRateFields.maxDailyRate] as num).toDouble() : null,
      createdAt: map[ParkingRateFields.createdAt] != null
          ? DateTime.tryParse(map[ParkingRateFields.createdAt] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }


  // Convert an instance to a Map
  Map<String, dynamic> toMap() {
    return {
      ParkingRateFields.rateId: rateId,
      ParkingRateFields.establishmentId: establishmentId,
      ParkingRateFields.rateType: rateType,
      ParkingRateFields.flatRate: flatRate,
      ParkingRateFields.baseRate: baseRate,
      ParkingRateFields.baseHours: baseHours,
      ParkingRateFields.extraHourlyRate: extraHourlyRate,
      ParkingRateFields.reserveRatePerHour: reserveRate,
      ParkingRateFields.maxDailyRate: maxDailyRate,
      ParkingRateFields.createdAt: createdAt.toIso8601String(),
    };
  }

  // Convert an instance to JSON
  String toJson() => json.encode(toMap());

  // Create an instance from JSON
  factory ParkingRate.fromJson(String source) =>
      ParkingRate.fromMap(json.decode(source));
}
