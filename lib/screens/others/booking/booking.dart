import 'package:eseepark/customs/custom_textfields.dart';
import 'package:eseepark/models/establishment_model.dart';
import 'package:eseepark/models/parking_section_model.dart';
import 'package:eseepark/models/reservation_model.dart';
import 'package:eseepark/screens/others/booking/partials/time_picker.dart';
import 'package:eseepark/screens/others/booking/partials/vehicle_picker.dart';
import 'package:eseepark/screens/others/booking/payment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../customs/custom_widgets.dart';
import '../../../globals.dart';
import '../../../main.dart';
import '../../../models/parking_rate_model.dart';
import '../../../models/parking_slot_model.dart';
import '../../../models/vehicle_model.dart';

class ReservationSlot {
  final int index;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;
  final double price;

  const ReservationSlot({
    required this.index,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.price
  });
}

class Booking extends StatefulWidget {
  final String slotId;
  final int availableSlots;
  final double? distance;

  const Booking({
    super.key,
    required this.slotId,
    required this.availableSlots,
    this.distance
  });

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  Map<String, dynamic> selectedTimeStatus = {};
  ReservationSlot? selectedReservationSlot;
  final ScrollController scrollController = ScrollController();
  Vehicle? selectedVehicle;
  Stream<List<Map<String, dynamic>>>? parkingStream;

  @override
  void initState() {
    super.initState();
    _setupParkingStream();
  }

  void _setupParkingStream() {
    parkingStream = supabase
        .from('parking_slots')
        .stream(primaryKey: ['slot_id'])
        .eq('slot_id', widget.slotId)
        .asyncMap((slots) async {
      if (slots.isNotEmpty) {
        final slot = slots.first;

        if(slot['status'] != 'available') {
          print('Oops! This slot is already occupied');

          return <Map<String, dynamic>>[];
        }

        final sectionData = await supabase
            .from('parking_sections')
            .select()
            .eq('section_id', slot['section_id'])
            .single();

        final establishmentData = await supabase
            .from('establishments')
            .select()
            .eq('establishment_id', sectionData['establishment_id'])
            .single();

        final parkingRatesData = await supabase
            .from('parking_rates')
            .select()
            .eq('establishment_id', sectionData['establishment_id'])
            .single();

        final vehicleData = await supabase
            .from('vehicles')
            .select()
            .eq('user_id', supabase.auth.currentUser!.id);

        return [
          {
            'slot': ParkingSlot.fromMap(slot),
            'section': ParkingSection.fromMap(sectionData),
            'establishment': Establishment.fromMap(establishmentData),
            'parking_rate': ParkingRate.fromMap(parkingRatesData),
            'vehicles': vehicleData.isNotEmpty ? vehicleData.map((e) => Vehicle.fromMap(e)).toList()  : []
          }
        ];
      }
      return <Map<String, dynamic>>[];
    }).asyncExpand((event) async* {
      yield event; // Yield the data received from asyncMap
    });

    setState(() {});
  }

  String getFormattedWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String getFormattedTime(String time) {
    // Split the time string by the colon
    List<String> parts = time.split(':');
    // Return the first part, which is the hour
    return parts.isNotEmpty ? parts[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: parkingStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return const Center(child: Text("No Data Available"));
          }

          final data = snapshot.data!.first;
          final slot = data['slot'] as ParkingSlot;
          final section = data['section'] as ParkingSection;
          final establishment = data['establishment'] as Establishment;
          final parkingRate = data['parking_rate'] as ParkingRate;
          final vehicles = data['vehicles'] as List<Vehicle>?;

          return Stack(
            children: [
              CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: screenHeight * 0.24, // Set an estimated height, this will be adjusted
                    pinned: true,
                    elevation: 1,
                    scrolledUnderElevation: 0,
                    centerTitle: true,
                    floating: true,
                    collapsedHeight: screenHeight * 0.24,
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        double maxHeight = constraints.maxHeight; // Dynamic height based on content
                        return FlexibleSpaceBar(
                          background: Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + screenHeight * 0.02, // Adjust for status bar
                              left: screenWidth * 0.04,
                              right: screenWidth * 0.04,
                              bottom: screenHeight * 0.02,
                            ),
                            decoration: BoxDecoration(color: Colors.white),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(onTap: () => Get.back(), splashColor: Colors.transparent, highlightColor: Colors.transparent, child: Icon(Icons.arrow_back, size: screenSize * 0.025)),
                                    SizedBox(width: screenWidth * 0.05),
                                    Expanded(
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          establishment.name,
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: screenSize * 0.018,
                                                              fontWeight: FontWeight.bold
                                                          ),
                                                        ),
                                                        Text(establishment.address,
                                                          style: TextStyle(
                                                            color: const Color(0xFF808080),
                                                            fontSize: screenSize * 0.01,
                                                            height: 1.3,
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: screenWidth * 0.05),
                                                Container(
                                                  width: screenWidth * 0.16,
                                                  height: screenWidth * 0.16,
                                                  decoration: BoxDecoration(
                                                    image: establishment.image != null ? DecorationImage(
                                                        image: NetworkImage(establishment.image ?? ''),
                                                        fit: BoxFit.cover
                                                    ) : null,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: screenWidth * 0.04),
                                            Row(
                                              children: [
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(context).colorScheme.primary,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        padding: EdgeInsets.all(screenWidth * 0.005),
                                                        child: Icon(
                                                          Icons.local_parking,
                                                          size: screenWidth * 0.04,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      SizedBox(width: screenWidth * 0.02),
                                                      Text("${widget.availableSlots} ${widget.availableSlots > 1 ? 'Slots' : 'Slot'} Available",
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: screenSize * 0.01,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: screenWidth * 0.05),
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(context).colorScheme.primary,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        padding: EdgeInsets.all(screenWidth * 0.005),
                                                        child: Icon(
                                                          Icons.location_pin,
                                                          size: screenWidth * 0.04,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      SizedBox(width: screenWidth * 0.02),
                                                      Text('${(widget.distance ?? 0).toStringAsPrecision(2)} km away',
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: screenSize * 0.01,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                InkWell(
                                  onTap: () async  {
                                    print('Latitude: ${establishment.coordinates['lat']}');
                                    print('Longitude: ${establishment.coordinates['lng']}');

                                    final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${establishment.coordinates['lat']},${establishment.coordinates['lng']}');

                                    if (!await launchUrl(url)) {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: Container(
                                    width: screenWidth,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).colorScheme.onPrimary, width: .3),
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.013,
                                        horizontal: screenWidth * 0.05
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.directions, color: Colors.white, size: screenWidth * 0.05),
                                        SizedBox(width: screenWidth * 0.02),
                                        Text('Get Directions',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenSize * 0.011,
                                              fontWeight: FontWeight.w600
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.02,
                            left: screenWidth * 0.04,
                            right: screenWidth * 0.04,
                            bottom: screenHeight * 0.02,
                          ),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Slot Details',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: screenSize * 0.015,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text('Section - Slot No. & Floor',
                                style: TextStyle(
                                    color: Color(0xFF808080).withValues(alpha: 0.7),
                                    fontSize: screenSize * 0.011,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Row(
                                children: [
                                  Text('${section.name}-${slot.slotNumber} • ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenSize * 0.012,
                                        fontWeight: FontWeight.w700
                                    ),
                                  ),
                                  Text('Floor ${section.floorLevel}',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenSize * 0.012,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text('Vehicle',
                                style: TextStyle(
                                    color: Color(0xFF808080).withValues(alpha: 0.7),
                                    fontSize: screenSize * 0.011,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return VehiclePicker(
                                            items: vehicles ?? [],
                                            titleKey: 'name',
                                            title: 'Select a Vehicle',
                                            selectedVehicle: selectedVehicle,
                                        );
                                      }
                                  ).then((val) {
                                    if(val is Vehicle) {
                                      setState(() {
                                        selectedVehicle = val;
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                  width: screenWidth,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD1D1D1).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.013,
                                      horizontal: screenWidth * 0.05
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(selectedVehicle == null ? 'Select a Vehicle' : selectedVehicle!.name.toString(),
                                        style: TextStyle(
                                            color: const Color(0xFF808080).withValues(alpha: 0.9),
                                            fontSize: screenSize * 0.012,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      Icon(Icons.arrow_drop_down, color: const Color(0xFF808080).withValues(alpha: 0.9),)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.02,
                            bottom: screenHeight * 0.02,
                          ),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: screenWidth * 0.04,
                                  right: screenWidth * 0.04,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Reservation Details',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: screenSize * 0.015,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    Text('Specify Entrance Time',
                                      style: TextStyle(
                                          color: Color(0xFF808080).withValues(alpha: 0.7),
                                          fontSize: screenSize * 0.011,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return SlotTimePicker(
                                                slotId: widget.slotId,
                                                selectedTimeStatus: selectedTimeStatus,
                                                startHour: int.parse(getFormattedTime(establishment.operatingHours.where((element) => element.day == getFormattedWeekday(DateTime.now().weekday)).first.open)),
                                                endHour: int.parse(getFormattedTime(establishment.operatingHours.where((element) => element.day == getFormattedWeekday(DateTime.now().weekday)).first.close)),
                                              );
                                            }
                                        ).then((val) {
                                          if(val is Map && val.isNotEmpty) {
                                            setState(() {
                                              selectedReservationSlot = null;
                                              selectedTimeStatus = val as Map<String, dynamic>;
                                            });

                                            print('Data: $selectedTimeStatus');
                                          } else {
                                            print('Empty');
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: screenWidth,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD1D1D1).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: screenHeight * 0.013,
                                            horizontal: screenWidth * 0.05
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(selectedTimeStatus['slotTime'] != null ? DateFormat('h:mm a').format(selectedTimeStatus['slotTime']) : 'Select a Time',
                                              style: TextStyle(
                                                  color: const Color(0xFF808080).withValues(alpha: 0.9),
                                                  fontSize: screenSize * 0.012,
                                                  fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            Icon(Icons.access_time, color: const Color(0xFF808080).withValues(alpha: 0.9),)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if(selectedTimeStatus['availableSlots'] != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: screenHeight * 0.02),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: screenWidth * 0.04,
                                        right: screenWidth * 0.04,
                                      ),
                                      child: Text('Select Parking Duration',
                                        style: TextStyle(
                                            color: Color(0xFF808080).withValues(alpha: 0.7),
                                            fontSize: screenSize * 0.011,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: screenWidth * 0.23,
                                      margin: EdgeInsets.only(top: screenHeight * 0.015),
                                      child: ListView.builder(
                                        itemCount: selectedTimeStatus['availableSlots'] ?? 0,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          // Calculate time duration in minutes
                                          int minutes = (index + 1) * 30;
                                          // Convert to hours and minutes format
                                          int hours = minutes ~/ 60;
                                          int remainingMinutes = minutes % 60;

                                          // Format the time string
                                          String durationText = hours > 0
                                              ? "$hours hr${hours > 1 ? 's' : ''}${remainingMinutes > 0 ? ' $remainingMinutes m' : ''}"
                                              : "$remainingMinutes min";

                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                if(selectedReservationSlot?.index == index) {
                                                  setState(() {
                                                    selectedReservationSlot = null;
                                                  });
                                                } else {
                                                  setState(() {
                                                    selectedReservationSlot = ReservationSlot(
                                                        index: index,
                                                        startTime: (selectedTimeStatus['slotTime'] as DateTime).toUtc(),
                                                        endTime: selectedTimeStatus['slotTime'].toUtc().add(Duration(minutes: minutes)),
                                                        duration: index + 1,
                                                        price: (index + 1) * (parkingRate.reserveRate ?? 0)
                                                    );
                                                  });

                                                  print('Selected Start Time: ${selectedReservationSlot?.startTime}');
                                                  print('Selected End Time: ${selectedReservationSlot?.endTime}');
                                                }
                                              });

                                              print('Selected: ${selectedReservationSlot?.endTime}');
                                            },
                                            borderRadius: BorderRadius.circular(10),
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 100),
                                              height: screenWidth * 0.23,
                                              width: screenWidth * 0.23,
                                              margin: EdgeInsets.only(
                                                left: index == 0 ? screenWidth * 0.04 : 0,
                                                right: index == (selectedTimeStatus['availableSlots'] ?? 0) - 1 ? screenWidth * 0.04 : screenWidth * 0.03,
                                              ),
                                              decoration: BoxDecoration(
                                                color: selectedReservationSlot?.index == index ? Theme.of(context).colorScheme.primary : const Color(0xFFD1D1D1).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(text: '₱', style: TextStyle(fontFamily: 'HelveticaNeue')),
                                                        TextSpan(text: '${(index + 1) * (parkingRate.reserveRate ?? 0)}'),
                                                      ],
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: screenSize * 0.013,
                                                        height: 1,
                                                        color: selectedReservationSlot?.index == index ? Colors.white : Theme.of(context).colorScheme.primary,
                                                        fontFamily: 'Poppins'
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    durationText, // Display the formatted time
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: screenSize * 0.009,
                                                      height: 1,
                                                      color: selectedReservationSlot?.index == index ? Colors.white : const Color(0xFF808080).withValues(alpha: 0.6),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.16),
                      ],
                    ),
                  )
                ],
              ),
              if(selectedReservationSlot != null)
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
                      SizedBox(height: screenHeight * 0.005),
                      Container(
                        // color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total ',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: screenSize * 0.0135,
                                fontWeight: FontWeight.w400,
                                height: 1
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(text: '₱', style: TextStyle(fontFamily: 'HelveticaNeue', height: 0.3, fontWeight: FontWeight.w400)),
                                  TextSpan(text: selectedReservationSlot?.price.toString() ?? '0',),
                                ],
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenSize * 0.018,
                                    height: 1.15,
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: 'Poppins'
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      ElevatedButton(
                        onPressed: () => Get.to(() => Payment(
                            establishment: establishment,
                            parkingRate: parkingRate,
                            vehicle: selectedVehicle,
                            reservation: Reservation(
                              userId: supabase.auth.currentUser!.id,
                              establishmentId: establishment.establishmentId,
                              slotId: widget.slotId,
                              vehicleId: selectedVehicle?.id,
                              status: 'pending',
                              startTime: selectedReservationSlot?.startTime ?? DateTime.now().toUtc(),
                              endTime: selectedReservationSlot?.endTime ?? DateTime.now().toUtc(),
                              createdAt: DateTime.now().toUtc(),
                              updatedAt: DateTime.now().toUtc(),
                              totalFee: selectedReservationSlot?.price ?? 0,
                            ),
                            selectedReservationSlot: selectedReservationSlot!,
                            otherDetails: {
                              'sectionAndSlotNo': {
                                'name': section.name,
                                'slotNo': slot.slotNumber
                              },
                              'vehicle': selectedVehicle
                            },
                          ),
                          transition: Transition.leftToRight,
                          duration: const Duration(milliseconds: 300),
                        ),
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
                            Text('Book Now',
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
              )
            ],
          );
        },
      ),
    );
  }
}
