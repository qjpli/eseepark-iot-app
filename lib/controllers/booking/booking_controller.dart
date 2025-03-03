import 'package:eseepark/main.dart';
import 'package:eseepark/models/payment_model.dart';
import 'package:eseepark/models/reservation_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingController {
  final supabase = Supabase.instance.client;

  Future<(PaymentModel?, Reservation?)> addReservationToDB(Reservation reservation, PaymentModel paymentModel) async {
    try {
      // Step 1: Insert payment details into 'payments' table
      final paymentResponse = await supabase.from('payments').insert({
        'user_id': paymentModel.userId,
        'amount': paymentModel.amount,
        'payment_method': paymentModel.paymentMethod,
        'payment_response_id': paymentModel.paymentResponseId,
        'status': paymentModel.status,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();

      if (paymentResponse == null || paymentResponse['payment_id'] == null) {
        throw Exception("Failed to insert payment.");
      }

      PaymentModel updatedPayment = PaymentModel(
        id: paymentResponse['payment_id'],
        userId: paymentResponse['user_id'],
        amount: paymentResponse['amount'],
        paymentMethod: paymentResponse['payment_method'],
        paymentResponseId: paymentResponse['payment_response_id'],
        status: paymentResponse['status'],
        createdAt: DateTime.parse(paymentResponse['created_at']),
        updatedAt: DateTime.parse(paymentResponse['updated_at']),
      );

      // Step 2: Insert reservation details into 'reservations' table
      final reservationResponse = await supabase.from('reservations').insert({
        'user_id': reservation.userId,
        'establishment_id': reservation.establishmentId,
        'slot_id': reservation.slotId,
        'vehicle_id': reservation.vehicleId,
        'status': reservation.status,
        'start_time': reservation.startTime.toIso8601String(),
        'end_time': reservation.endTime.toIso8601String(),
        'total_fee': reservation.totalFee,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'payment_id': updatedPayment.id,
      }).select().single();

      if (reservationResponse == null || reservationResponse['reservation_id'] == null) {
        throw Exception("Failed to insert reservation.");
      }

      Reservation updatedReservation = Reservation(
        id: reservationResponse['reservation_id'],
        userId: reservationResponse['user_id'],
        establishmentId: reservationResponse['establishment_id'],
        slotId: reservationResponse['slot_id'],
        vehicleId: reservationResponse['vehicle_id'],
        status: reservationResponse['status'],
        startTime: DateTime.parse(reservationResponse['start_time']),
        endTime: DateTime.parse(reservationResponse['end_time']),
        totalFee: reservationResponse['total_fee'],
        createdAt: DateTime.parse(reservationResponse['created_at']),
        updatedAt: DateTime.parse(reservationResponse['updated_at']),
        payment: updatedPayment,
      );

      print('Added reservation and payment to database');

      return (updatedPayment, updatedReservation);
    } catch (e) {
      print('Error adding reservation to database: $e');
      return (null, null);
    }
  }
}
