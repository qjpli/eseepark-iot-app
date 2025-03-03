import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:eseepark/models/reservation_model.dart';
import 'package:eseepark/models/vehicle_model.dart';
import 'package:eseepark/screens/others/booking/booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../globals.dart';

class Payment extends StatefulWidget {
  final Reservation reservation;
  final ReservationSlot selectedReservationSlot;
  final Map<String, dynamic> otherDetails;

  const Payment({
    super.key,
    required this.reservation,
    required this.selectedReservationSlot,
    required this.otherDetails
  });

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  
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
    return Scaffold(
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
      body: Container(
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
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${(widget.otherDetails['vehicle'] as Vehicle).name}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: screenWidth * 0.045,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis
                        ),
                        Text('SM Marikina City',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w400,
                              fontSize: screenWidth * 0.03
                          ),
                        )
                      ],
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
              // decoration: DottedDecoration(
              //   color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              //   strokeWidth: 0.5,
              //   dash: [7, 6],
              //   linePosition: LinePosition.bottom,
              // ),
              child: Column(
                children: [
                  InfoWidget(
                    title: 'Subtotal',
                    value: widget.selectedReservationSlot.price.toStringAsFixed(2),
                    isCurrency: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

