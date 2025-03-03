import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:eseepark/main.dart';
import 'package:eseepark/models/establishment_model.dart';
import 'package:eseepark/models/payment_model.dart';
import 'package:eseepark/models/reservation_model.dart';
import 'package:eseepark/models/vehicle_model.dart';
import 'package:eseepark/screens/others/booking/booking.dart';
import 'package:eseepark/screens/others/booking/partials/payment_methods.dart';
import 'package:eseepark/screens/others/booking/success_payment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import '../../../controllers/booking/booking_controller.dart';
import '../../../globals.dart';
import '../../../models/parking_rate_model.dart';

class Payment extends StatefulWidget {
  final Establishment establishment;
  final Vehicle? vehicle;
  final ParkingRate parkingRate;
  final Reservation reservation;
  final ReservationSlot selectedReservationSlot;
  final Map<String, dynamic> otherDetails;

  const Payment({
    super.key,
    required this.establishment,
    required this.vehicle,
    required this.parkingRate,
    required this.reservation,
    required this.selectedReservationSlot,
    required this.otherDetails
  });

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final BookingController bookingController = BookingController();
  PaymentMethod? selectedPaymentMethod;

  bool isPaymentSuccess = false;

  String durationFormatter(int minuteMultiplier) {
    int minutes = widget.selectedReservationSlot.duration * 30;

    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;

    String durationText = hours > 0
        ? "$hours hr${hours > 1 ? 's' : ''}${remainingMinutes > 0 ? ' $remainingMinutes m' : ''}"
        : "$remainingMinutes min";
    
    return durationText;
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('Payment',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary
              ),
            ),
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: Stack(
            children: [
              Container(
                child: ListView(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: BoxConstraints(
                                minWidth: screenWidth * 0.14,
                                minHeight: screenWidth * 0.14
                            ),
                            margin: EdgeInsets.only(
                                right: screenWidth * 0.03
                            ),
                            alignment: Alignment.center,
                            child: Text('${widget.otherDetails['sectionAndSlotNo']['name']}-${widget.otherDetails['sectionAndSlotNo']['slotNo']}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth * 0.04
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
                                        fontSize: screenWidth * 0.045,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis
                                  ),
                                  Text(widget.establishment.name,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                                        fontWeight: FontWeight.w400,
                                        fontSize: screenWidth * 0.03
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
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                      ),
                      decoration: DottedDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                        strokeWidth: 0.5,
                        dash: [7, 6],
                        linePosition: LinePosition.bottom,
                      ),
                      child: Column(
                        children: [
                          InfoWidget(
                            title: 'Booking Date',
                            value: DateFormat('MMM dd, yyyy').format(widget.reservation.createdAt),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          InfoWidget(
                            title: 'Slot No.',
                            value: '${widget.otherDetails['sectionAndSlotNo']['name']}-${widget.otherDetails['sectionAndSlotNo']['slotNo']}',
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          InfoWidget(
                            title: 'Slot No.',
                            value: '${widget.otherDetails['sectionAndSlotNo']['name']}-${widget.otherDetails['sectionAndSlotNo']['slotNo']}',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                      ),
                      decoration: DottedDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                        strokeWidth: 0.5,
                        dash: [7, 6],
                        linePosition: LinePosition.bottom,
                      ),
                      child: Column(
                        children: [
                          InfoWidget(
                            title: 'Arrival Time',
                            value: DateFormat('h:mm a').format(widget.selectedReservationSlot.startTime),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          InfoWidget(
                            title: 'Exit On or Before',
                            value: DateFormat('h:mm a').format(widget.selectedReservationSlot.endTime),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          InfoWidget(
                            title: 'Duration',
                            value: durationFormatter(30),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                      ),
                      decoration: DottedDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                        strokeWidth: 0.5,
                        dash: [7, 6],
                        linePosition: LinePosition.bottom,
                      ),
                      child: Column(
                        children: [
                          InfoWidget(
                            title: 'Subtotal',
                            value: widget.selectedReservationSlot.price.toStringAsFixed(2),
                            isCurrency: true,
                          ),
                          SizedBox(height: screenHeight * 0.025),
                          Container(
                            width: screenWidth,
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.016,
                                horizontal: screenWidth * 0.03
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                  width: 1.2
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Tap to view Voucher',
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w500,
                                      fontSize: screenWidth * 0.033
                                  ),
                                ),
                                Icon(Icons.discount_outlined,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                  size: screenWidth * 0.04,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.02
                      ),
                      // decoration: DottedDecoration(
                      //   color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                      //   strokeWidth: 0.5,
                      //   dash: [7, 6],
                      //   linePosition: LinePosition.bottom,
                      // ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select a Payment Method',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Container(
                            width: screenWidth,
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.013,
                              horizontal: screenWidth * 0.03
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                width: 1.2
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: PaymentMethod(
                              index: 0,
                              svgAsset: 'assets/svgs/payment/paypal-logo.svg',
                              title: 'PayPal'
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: screenWidth,
                    padding: EdgeInsets.only(
                        left: screenWidth * 0.05,
                        right: screenWidth * 0.05,
                        top: screenHeight * 0.015,
                        bottom: screenHeight * 0.03
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 5), // changes position of shadow
                          ),
                        ]
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.0,
                          ),
                          // color: Colors.red,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                              Container(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(text: '₱', style: TextStyle(fontFamily: 'HelveticaNeue', fontWeight: FontWeight.w400)),
                                      TextSpan(text: widget.selectedReservationSlot.price.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
                                    ],
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: screenWidth * 0.055,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        ElevatedButton(
                            onPressed: () {
                              Get.to(() => PayPalView(
                                  amount: widget.selectedReservationSlot.price,
                                  sandboxMode: true,
                                  items: [
                                    PayPalItem(
                                      name: 'Booking',
                                      price: widget.selectedReservationSlot.price,
                                      quantity: 1,
                                      currency: 'PHP'
                                    )
                                  ],
                                  onSuccess: (Map params) async {
                                    print("onSuccess Output: $params");
                                    String message = params['message'];

                                    if(message == 'Success') {
                                      var data = params['data'];
                                      String id = data['id'];
                                      String state = data['state'];

                                      PaymentModel paymentModel = PaymentModel(
                                        userId: supabase.auth.currentUser!.id,
                                        amount: widget.selectedReservationSlot.price,
                                        paymentMethod: 'paypal',
                                        status: 'paid',
                                        paymentResponseId: id,
                                        createdAt: DateTime.now().toUtc(),
                                        updatedAt: DateTime.now().toUtc()
                                      );

                                      Reservation reservation = widget.reservation.copyWith(
                                        payment: paymentModel
                                      );

                                      final (updatedPayment, updatedReservation) = await bookingController.addReservationToDB(reservation, paymentModel);

                                      if (updatedPayment != null && updatedReservation != null) {
                                        print('Success Payment');

                                        Map<String, dynamic> result = {
                                          'establishment': widget.establishment,
                                          'parkingRate': widget.parkingRate,
                                          'vehicle': widget.vehicle,
                                          'finalPayment': updatedPayment,
                                          'finalReservation': updatedReservation,
                                          'otherDetails': widget.otherDetails,
                                          'reservationDuration': widget.selectedReservationSlot.duration
                                        };

                                        Get.back(result: result);

                                        setState(() {
                                          isPaymentSuccess = true;
                                        });

                                        Future.delayed(Duration(seconds: 2), () {
                                          Get.offAll(() => SuccessPayment(
                                              establishment: result['establishment'],
                                              parkingRate: result['parkingRate'],
                                              vehicle: result['vehicle'],
                                              finalPayment: result['finalPayment'],
                                              finalReservation: result['finalReservation'],
                                              otherDetails: result['otherDetails'],
                                              reservationDuration: result['reservationDuration']
                                            ),
                                            transition: Transition.downToUp,
                                            duration: const Duration(milliseconds: 500),
                                          );
                                        });
                                      } else {
                                        Get.back();
                                      }

                                    }
                                  }
                                )
                              )?.then((val) {

                                if(val != null) {
                                  if(val is Map) {

                                  }
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: screenHeight * 0.018
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Pay Now',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white
                                  ),
                                )
                              ],
                            )
                        ),
                      ],
                    )
                ),
              ),
            ],
          ),
        ),
        if(isPaymentSuccess)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Stack(
            children: [
              // Blur effect
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 4.0),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            radius: screenWidth * 0.065,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Material(
                            child: Text('Please wait...',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                                fontSize: screenWidth * 0.035
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class InfoWidget extends StatefulWidget {
  final String title;
  final String value;
  final bool isCurrency;
  final String currencyFormat;

  const InfoWidget({
    super.key,
    required this.title,
    required this.value,
    this.isCurrency = false,
    this.currencyFormat = '₱',
  });

  @override
  State<InfoWidget> createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
            ),
          ),
          Container(
            child: widget.isCurrency ? RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: widget.currencyFormat, style: TextStyle(fontFamily: 'HelveticaNeue', fontWeight: FontWeight.w400)),
                  TextSpan(text: widget.value, style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
                ],
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500
                ),
              ),
            ) : Text(widget.value,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins'
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PaymentMethod extends StatefulWidget {
  final int index;
  final String svgAsset;
  final String title;

  const PaymentMethod({
    super.key,
    required this.index,
    required this.svgAsset,
    required this.title
  });

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            SizedBox(width: screenWidth * 0.01),
            SvgPicture.asset(widget.svgAsset,
              width: screenWidth * 0.06,
            ),
            SizedBox(width: screenWidth * 0.04),
            Text(widget.title,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.033
              ),
            )
          ],
        ),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
          size: screenWidth * 0.06,
        )
      ],
    );
  }
}


