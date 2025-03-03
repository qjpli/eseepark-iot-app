import 'dart:convert';

class PaymentFields {
  static const String id = 'payment_id';
  static const String userId = 'user_id';
  static const String amount = 'amount';
  static const String paymentMethod = 'payment_method';
  static const String paymentResponseId = 'payment_response_id';
  static const String status = 'status';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class PaymentModel {
  final String? id;
  final String userId;
  final double amount;
  final String paymentMethod;
  final String? paymentResponseId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    this.id,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    this.paymentResponseId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map[PaymentFields.id] as String? ?? '',
      userId: map[PaymentFields.userId] as String? ?? '',
      amount: map[PaymentFields.amount] != null ? (map[PaymentFields.amount] as num).toDouble() : 0.0,
      paymentMethod: map[PaymentFields.paymentMethod] as String? ?? '',
      paymentResponseId: map[PaymentFields.paymentResponseId] as String? ?? '',
      status: map[PaymentFields.status] as String? ?? '',
      createdAt: DateTime.tryParse(map[PaymentFields.createdAt] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map[PaymentFields.updatedAt] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      PaymentFields.id: id,
      PaymentFields.userId: userId,
      PaymentFields.amount: amount,
      PaymentFields.paymentMethod: paymentMethod,
      PaymentFields.paymentResponseId: paymentResponseId,
      PaymentFields.status: status,
      PaymentFields.createdAt: createdAt.toIso8601String(),
      PaymentFields.updatedAt: updatedAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());
}
