import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:eseepark/models/establishment_model.dart';
import 'package:eseepark/models/parking_rate_model.dart';
import 'package:eseepark/models/vehicle_model.dart';
import 'package:eseepark/screens/others/booking/payment.dart';
import 'package:eseepark/screens/others/hub.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:torn_ticket/torn_ticket.dart';

import '../../../globals.dart';
import '../../../models/payment_model.dart';
import '../../../models/reservation_model.dart';

class SuccessPayment extends StatefulWidget {
  final Establishment establishment;
  final Vehicle? vehicle;
  final ParkingRate parkingRate;
  final Reservation finalReservation;
  final PaymentModel finalPayment;
  final Map<String, dynamic> otherDetails;
  final int reservationDuration;

  const SuccessPayment({
    super.key,
    required this.establishment,
    required this.vehicle,
    required this.parkingRate,
    required this.finalReservation,
    required this.finalPayment,
    required this.otherDetails,
    required this.reservationDuration
  });

  @override
  State<SuccessPayment> createState() => _SuccessPaymentState();
}

class _SuccessPaymentState extends State<SuccessPayment> {

  String durationFormatter(int minuteMultiplier) {
    int minutes = widget.reservationDuration * 30;

    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;

    String durationText = hours > 0
        ? "$hours hr${hours > 1 ? 's' : ''}${remainingMinutes > 0 ? ' $remainingMinutes m' : ''}"
        : "$remainingMinutes min";

    return durationText;
  }
  
  String paymentMethodFormatter(String paymentMethod) {
    
    String paymentMethodText = paymentMethod.toLowerCase();
    
    if(paymentMethodText == 'paypal') {
      return 'PayPal';
    } else {
      return 'Credit Card';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: Container(
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                TornTicket(
                  margin: EdgeInsets.only(top: screenHeight * 0.06),
                  height: screenHeight * 0.65,
                  cutoutHeight: screenHeight * 0.02,
                  borderRadius: 30,
                  hasShadow: false,
                  shadowColor: Colors.white.withValues(alpha: 0.3),
                  shadowOffset: Offset(0, 0),
                  shadowBlur: 30,
                  bottomArcSpacing: 16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: screenHeight * 0.04),
                          Text('Payment Successful',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: '₱', style: TextStyle(fontFamily: 'HelveticaNeue')),
                                TextSpan(text: widget.finalPayment.amount.toStringAsFixed(2)),
                              ],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenSize * 0.019,
                                  height: 1,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: 'Poppins'
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            margin: EdgeInsets.symmetric(
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                                horizontal: screenWidth * 0.02
                            ),
                            decoration: DottedDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                              strokeWidth: 0.5,
                              dash: [7, 6],
                              linePosition: LinePosition.bottom,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  constraints: BoxConstraints(
                                      minWidth: screenWidth * 0.1,
                                      minHeight: screenWidth * 0.1
                                  ),
                                  margin: EdgeInsets.only(
                                      right: screenWidth * 0.03
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('${widget.otherDetails['sectionAndSlotNo']['name']}-${widget.otherDetails['sectionAndSlotNo']['slotNo']}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: screenWidth * 0.03
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text((widget.otherDetails['vehicle'] as Vehicle).name,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: screenWidth * 0.035,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis
                                        ),
                                        Text(widget.establishment.name,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                                                fontWeight: FontWeight.w400,
                                                fontSize: screenWidth * 0.025
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Container(
                            padding: EdgeInsets.only(
                                bottom: screenHeight * 0.02
                            ),
                            decoration: DottedDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                              strokeWidth: 0.5,
                              dash: [7, 6],
                              linePosition: LinePosition.bottom,
                            ),
                            child: Column(
                              children: [
                                ReceiptInfoWidget(
                                  title: 'Booking Date',
                                  value: DateFormat('MMM dd, yyyy').format(widget.finalReservation.createdAt),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                ReceiptInfoWidget(
                                  title: 'Slot No.',
                                  value: '${widget.otherDetails['sectionAndSlotNo']['name']}-${widget.otherDetails['sectionAndSlotNo']['slotNo']}',
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                ReceiptInfoWidget(
                                  title: 'Arrival Time',
                                  value: DateFormat('h:mm a').format(widget.finalReservation.startTime),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                ReceiptInfoWidget(
                                  title: 'Exit On or Before',
                                  value: DateFormat('h:mm a').format(widget.finalReservation.endTime),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                ReceiptInfoWidget(
                                  title: 'Duration',
                                  value: durationFormatter(30),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              top: screenHeight * 0.02,
                              bottom: screenHeight * 0.02
                            ),
                            decoration: DottedDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                              strokeWidth: 0.5,
                              dash: [7, 6],
                              linePosition: LinePosition.bottom,
                            ),
                            child: Column(
                              children: [
                                ReceiptInfoWidget(
                                  title: 'Payment Method',
                                  value: paymentMethodFormatter(widget.finalPayment.paymentMethod),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        width: screenWidth,
                        child: ElevatedButton(
                          onPressed: () => Get.offAll(() => Hub(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 300),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.011,
                              horizontal: screenWidth * 0.05
                            ),
                            elevation: 0
                          ),
                          child: Text('Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.033,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle
                    ),
                    child: Icon(Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: screenWidth * 0.2,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      )
    );
  }
}

class ReceiptInfoWidget extends StatefulWidget {
  final String title;
  final String value;
  final bool isCurrency;
  final String currencyFormat;

  const ReceiptInfoWidget({
    super.key,
    required this.title,
    required this.value,
    this.isCurrency = false,
    this.currencyFormat = '₱',
  });

  @override
  State<ReceiptInfoWidget> createState() => _ReceiptInfoWidgetState();
}

class _ReceiptInfoWidgetState extends State<ReceiptInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.005,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(widget.title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                fontSize: screenWidth * 0.029
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: widget.isCurrency ? RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: widget.currencyFormat, style: TextStyle(fontFamily: 'HelveticaNeue', fontWeight: FontWeight.w400)),
                    TextSpan(text: widget.value, style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
                  ],
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.029
                  ),
                ),
              ) : Text(widget.value,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.029
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
