import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wheel_slider/wheel_slider.dart';
import '../../../../globals.dart';
import '../../../../main.dart';
import '../../../../models/reservation_model.dart';

class SlotTimePicker extends StatefulWidget {
  final String slotId;
  final Map<String, dynamic> selectedTimeStatus;
  final int startHour; // Start hour for operating hours (e.g., 7 for 7 AM)
  final int endHour; // End hour for operating hours (e.g., 22 for 10 PM)

  const SlotTimePicker({
    super.key,
    required this.slotId,
    required this.selectedTimeStatus,
    this.startHour = 7, // Default to 7 AM
    this.endHour = 22, // Default to 10 PM
  });

  @override
  _SlotTimePickerState createState() => _SlotTimePickerState();
}

class _SlotTimePickerState extends State<SlotTimePicker> {
  Map<String, dynamic> selectedSlotStatus = {};
  Map<String, List<DateTime>> timeSlots = {
    '0': [],
    '1': [],
  };
  final List<String> meridiemIndicator = ['AM', 'PM'];
  DateTime slotTime = DateTime.now();
  int selectedMeridiemIndex = 0;
  Map<String, int> selectedTimeIndex = {
    '0': 0,
    '1': 0,
  };

  final FixedExtentScrollController _timeController = FixedExtentScrollController();
  final FixedExtentScrollController _meridiemController = FixedExtentScrollController();
  Stream<List<Map<String, dynamic>>>? slotReservationStream;
  Set<String> reservedTimes = {};
  int availableSlots = 0;

  bool isAllowed = false;

  bool isScrolled = false;

  @override
  void initState() {
    super.initState();
    initializeSetup();
  }

  Future<void> generateTimeSlots() async {
    timeSlots['0'] = [];
    timeSlots['1'] = [];

    // Generate AM slots based on startHour and endHour
    for (int hour = widget.startHour; hour < 12 && hour < widget.endHour; hour++) {
      timeSlots['0']!.add(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, 0));
      if (hour + 0.5 < widget.endHour) { // Ensure it doesn't exceed closing hour
        timeSlots['0']!.add(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, 30));
      }
    }

    // Add PM slots from 12:00 PM to endHour
    for (int hour = 12; hour < widget.endHour; hour++) { // Changed <= to < to avoid adding endHour
      timeSlots['1']!.add(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, 0));
      if (hour + 0.5 < widget.endHour) { // Ensure it doesn't exceed closing hour
        timeSlots['1']!.add(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, 30));
      }
    }
  }



  void initializeSetup() async {
    await generateTimeSlots();
    await _setupParkingStream();
  }

  Future<void> _setupParkingStream() async {

   await Future.delayed(Duration(seconds: 0), () {
     slotReservationStream = supabase
         .from('reservations')
         .stream(primaryKey: ['slot_id'])
         .eq('slot_id', widget.slotId)
         .asyncMap((reservations) async {
       if (reservations.isNotEmpty) {
         List<Reservation> validReservations = reservations
             .map((e) => Reservation.fromMap(e))
             .where((res) =>
         res.status != 'completed' &&
             res.status != 'cancelled' &&
             res.status != 'expired')
             .toList();

         reservedTimes = validReservations.map((res) {
           return DateFormat('yyyy-MM-dd h:mm a').format(res.startTime);
         }).toSet();

         print(reservedTimes);
       }
       return [
         {'reservations': reservations.map((e) => Reservation.fromMap(e)).toList()}
       ];
     });


     setState(() {});
   });
  }

  String formatTime(DateTime time) {
    return DateFormat('h:mm').format(time);
  }

  String formatSelectedTime({String format = 'yyyy-MM-dd h:mm a'}) {
    DateTime selectedTime = timeSlots[selectedMeridiemIndex.toString()]![selectedTimeIndex[selectedMeridiemIndex.toString()]!];
    String meridiem = meridiemIndicator[selectedMeridiemIndex];

    int hour = selectedTime.hour;

    DateTime finalTime = DateTime(
      selectedTime.year,
      selectedTime.month,
      selectedTime.day,
      hour,
      selectedTime.minute,
    );

    return DateFormat(format).format(finalTime);
  }
  int getAvailableSlots(DateTime selectedTime, List<Reservation> reservations) {
    int availableCount = 0;

    print('Selected Time: $selectedTime');

    setState(() {
      slotTime = selectedTime;
    });

    // Get relevant time slots based on selectedMeridiemIndex
    List<DateTime> relevantSlots = [];

    // If AM, consider both AM and PM slots
    if (selectedMeridiemIndex == 0) {
      relevantSlots.addAll(timeSlots['0']!); // AM slots
      relevantSlots.addAll(timeSlots['1']!); // PM slots
    } else {
      relevantSlots = timeSlots['1']!; // Only PM slots
    }

    for (DateTime slot in relevantSlots) {
      DateTime adjustedSlotTime = DateTime.utc(
        slot.year,
        slot.month,
        slot.day,
        slot.hour,
        slot.minute,
      );

      // Skip if the slot time is before the selected time
      if (adjustedSlotTime.isBefore(selectedTime)) {
        continue;
      }

      // Check for reservations
      bool isReserved = reservations.any((reservation) {
        DateTime reservationStartTime = DateTime.utc(
          reservation.startTime.year,
          reservation.startTime.month,
          reservation.startTime.day,
          reservation.startTime.hour,
          reservation.startTime.minute,
        );
        DateTime reservationEndTime = DateTime.utc(
          reservation.endTime.year,
          reservation.endTime.month,
          reservation.endTime.day,
          reservation.endTime.hour,
          reservation.endTime.minute,
        );

        bool overlaps = (adjustedSlotTime.isAfter(reservationStartTime) && adjustedSlotTime.isBefore(reservationEndTime)) ||
            adjustedSlotTime.isAtSameMomentAs(reservationStartTime) ||
            adjustedSlotTime.isAtSameMomentAs(reservationEndTime);

            return overlaps;
        });

      if (isReserved) {
        print('Slot: $adjustedSlotTime is reserved. Stopping count.');
        break; // Stop counting available slots if one is reserved
      }

      // If the slot is available, increment the count
      availableCount++;
    }

    print('Total available slots from selected time: $availableCount');
    return availableCount;
  }

  void setTime() {
    DateTime time = DateTime.now();

    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        if (time.hour < 12) {
          print('AM');
          selectedMeridiemIndex = 0;
        } else {
          print('PM');
          selectedMeridiemIndex = 1;
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _meridiemController.animateToItem(selectedMeridiemIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      });
    })
        .then((val) {
      // Get the current hour and minute
      int adjustedHour = time.hour; // Get the current hour
      int adjustedMinute = time.minute; // Get the current minute

      print('Current time: $time');


      // Round to the nearest 30 minutes
      if (adjustedMinute < 30) {
        adjustedMinute = 30; // Set to 30 minutes
      } else {
        adjustedMinute = 0; // Set to 0 minutes
        adjustedHour += 1; // Move to the next hour
        if (adjustedHour == 24) {
          adjustedHour = 0; // If it goes past midnight, set to 0
        }
      }

      // Find the first time slot matching the adjusted hour and minute
      var matchingSlot = timeSlots[selectedMeridiemIndex.toString()]?.firstWhereOrNull(
              (slot) => slot.hour == adjustedHour && slot.minute == adjustedMinute
      );

      if (matchingSlot != null) {
        int? index = timeSlots[selectedMeridiemIndex.toString()]?.indexOf(matchingSlot);

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _timeController.animateToItem(index ?? 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        });
      } else {
        print('No matching time slot found for hour: $adjustedHour and minute: $adjustedMinute');
      }
    });

    isScrolled = true;
  }

  void setTimeStatus() async {
      setState(() {
        selectedSlotStatus = widget.selectedTimeStatus;
        selectedMeridiemIndex = widget.selectedTimeStatus['selectedMeridiemIndex'];
        selectedTimeIndex = widget.selectedTimeStatus['selectedTimeIndex'];
        slotTime = widget.selectedTimeStatus['slotTime'];
      });

    Future.delayed(Duration(milliseconds: 300), () {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _meridiemController.animateToItem(selectedMeridiemIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
        _timeController.animateToItem(selectedTimeIndex[widget.selectedTimeStatus['selectedMeridiemIndex'].toString()] ?? 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      });
    });

    isScrolled = true;
  }

  @override
  void dispose() {
    _timeController.dispose();
    _meridiemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: slotReservationStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }

        final reservations = (snapshot.data?.isNotEmpty == true)
            ? snapshot.data!.first['reservations'] as List<Reservation>
            : [];

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!isScrolled) {
            if(widget.selectedTimeStatus.isNotEmpty) {
              setTimeStatus();
            } else {
              setTime();
            }
          }
        });

        return Container(
          height: screenHeight * 0.45,
          width: screenWidth,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.05,
                    right: screenWidth * 0.05,
                    top: screenHeight * 0.03,
                    bottom: screenHeight * 0.01
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text('Select Entry Time',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: screenWidth * 0.05
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2
                            )
                        ),
                        padding: EdgeInsets.all(screenSize * 0.001),
                        child: Icon(Icons.close,
                            color: Theme.of(context).colorScheme.primary,
                            size: screenWidth * 0.06
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TIME PICKER (30-minute intervals)
                  Stack(
                    children: [
                      Container(
                        height: screenHeight * 0.25,
                        child: WheelSlider.customWidget(
                          totalCount: timeSlots.length, // 24 values for 30-minute intervals
                          initValue: 0, // Start at the first available time
                          isInfinite: false,
                          onValueChanged: (val) {
                            setState(() {
                              selectedTimeIndex[selectedMeridiemIndex.toString()] = val;
                            });

                            int hour = timeSlots[selectedMeridiemIndex.toString()]?[val].hour ?? 0;
                            int minute = timeSlots[selectedMeridiemIndex.toString()]?[val].minute ?? 0;

                            // Adjust hour based on selected meridiem
                            // if (selectedMeridiemIndex == 1) { // 1 means PM
                            //   if (hour != 12) {
                            //     hour += 12; // Convert to 24-hour format
                            //   }
                            // } else { // AM case
                            //   if (hour == 12) {
                            //     hour = 0; // Midnight case
                            //   }
                            // }

                            // Create a DateTime object for the current time slot in UTC
                            slotTime = DateTime.utc(
                              timeSlots[selectedMeridiemIndex.toString()]?[val].year ?? DateTime.now().year,
                              timeSlots[selectedMeridiemIndex.toString()]?[val].month ?? DateTime.now().month,
                              timeSlots[selectedMeridiemIndex.toString()]?[val].day ?? DateTime.now().day,
                              hour,
                              minute,
                            );



                            // Get the current time in UTC for comparison
                            DateTime now = DateTime.utc(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              DateTime.now().hour,
                              DateTime.now().minute
                            );

                            // Check if the slot time is in the past
                            bool isPast = slotTime.isBefore(now);

                            if (!isPast) {
                              // print('Its not past because $slotTime is not before $now');
                            }

                            // Check if the slot time is reserved based on start and end times
                            bool isReserved = reservations.any((reservation) {
                              if (reservation.startTime.isBefore(reservation.endTime)) {
                                DateTime reservationStartTime = DateTime.utc(
                                  reservation.startTime.year,
                                  reservation.startTime.month,
                                  reservation.startTime.day,
                                  reservation.startTime.hour,
                                  reservation.startTime.minute,
                                );
                                DateTime reservationEndTime = DateTime.utc(
                                  reservation.endTime.year,
                                  reservation.endTime.month,
                                  reservation.endTime.day,
                                  reservation.endTime.hour,
                                  reservation.endTime.minute,
                                );

                                bool overlaps = (slotTime.isAfter(reservationStartTime) && slotTime.isBefore(reservationEndTime)) ||
                                    (slotTime.isAtSameMomentAs(reservationStartTime) || slotTime.isAtSameMomentAs(reservationEndTime)) ||
                                    (reservationStartTime.isBefore(slotTime) && reservationEndTime.isAfter(slotTime)) ||
                                    (slotTime.isAtSameMomentAs(reservationStartTime)); // Include exact match for startTime

                                return overlaps;
                              }
                              return false; // Not a valid reservation
                            });

                            // Set isAllowed based on whether the slot is reserved or in the past
                            setState(() {
                              isAllowed = !isReserved && !isPast; // Allow if not reserved and not in the past
                            });

                            print('Time Slot Changed to: $slotTime');
                            print('Is Past: $isPast');
                            print('Is Reserved: $isReserved');
                            int slotsAvail = getAvailableSlots(slotTime, reservations as List<Reservation>);
                            print('Available slots for booking 2: $slotsAvail');

                            setState(() {
                              availableSlots = slotsAvail;
                            });
                          },
                          enableAnimation: true,
                          hapticFeedbackType: HapticFeedbackType.vibrate,
                          showPointer: false,
                          itemSize: screenHeight * 0.045,
                          controller: _timeController,
                          verticalListWidth: screenWidth * 0.22,
                          horizontal: false,
                          children: (timeSlots[selectedMeridiemIndex.toString()] ?? []).asMap().entries.map((entry) {
                            final index = entry.key;
                            final time = entry.value;
                            int hour = time.hour;
                            int minute = time.minute;

                            // Create a DateTime object for the current time slot in UTC
                            DateTime slotTime = DateTime.utc(
                              time.year,
                              time.month,
                              time.day,
                              hour,
                              minute,
                            );

                            // Get the current time in UTC for comparison
                            DateTime now = DateTime.utc(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                DateTime.now().hour,
                                DateTime.now().minute
                            );

                            // Check if the slot time is in the past
                            bool isPast = slotTime.isBefore(now);

                            if (isPast) {
                              // print('Its past because $slotTime is before $now');
                            }

                            // Check if the slot time is reserved based on start and end times
                            bool isReserved = reservations.any((reservation) {
                              if (reservation.startTime.isBefore(reservation.endTime)) {
                                DateTime reservationStartTime = DateTime.utc(
                                  reservation.startTime.year,
                                  reservation.startTime.month,
                                  reservation.startTime.day,
                                  reservation.startTime.hour,
                                  reservation.startTime.minute,
                                );
                                DateTime reservationEndTime = DateTime.utc(
                                  reservation.endTime.year,
                                  reservation.endTime.month,
                                  reservation.endTime.day,
                                  reservation.endTime.hour,
                                  reservation.endTime.minute,
                                );

                                bool overlaps = (slotTime.isAfter(reservationStartTime) && slotTime.isBefore(reservationEndTime)) ||
                                    (slotTime.isAtSameMomentAs(reservationStartTime) || slotTime.isAtSameMomentAs(reservationEndTime)) ||
                                    (reservationStartTime.isBefore(slotTime) && reservationEndTime.isAfter(slotTime)) ||
                                    (slotTime.isAtSameMomentAs(reservationStartTime)); // Include exact match for startTime

                                return overlaps;
                              }
                              return false; // Not a valid reservation
                            });

                            return InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                WidgetsBinding.instance.addPostFrameCallback((_) async {
                                  _timeController.animateToItem(index,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut);
                                });

                                // Existing onTap logic can go here if needed
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  formatTime(time),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: screenWidth * 0.05,
                                    letterSpacing: 1,
                                    color: isReserved || isPast ? Colors.grey : Colors.black,
                                    fontWeight: isReserved || isPast ? FontWeight.w300 : FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.1,
                        bottom: screenHeight * 0.1,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Container(
                            width: screenWidth * 0.03,
                            height: screenHeight * 0.03,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Stack(
                    children: [
                      Container(
                        height: screenHeight * 0.25,
                        child: WheelSlider.customWidget(
                          totalCount: 2,
                          initValue: 0,
                          isInfinite: false,
                          onValueChanged: (val) {
                            Future.delayed((Duration.zero), () {
                              setState(() {
                                selectedMeridiemIndex = val;
                              });
                              print(formatSelectedTime());

                              int hour = timeSlots[selectedMeridiemIndex.toString()]?[selectedTimeIndex[selectedMeridiemIndex.toString()] ?? 0].hour ?? 0;
                              int minute = timeSlots[selectedMeridiemIndex.toString()]?[selectedTimeIndex[selectedMeridiemIndex.toString()] ?? 0].minute ?? 0;

                              slotTime = DateTime.utc(
                                timeSlots[selectedMeridiemIndex.toString()]?[selectedTimeIndex[selectedMeridiemIndex.toString()] ?? 0].year ?? DateTime.now().year,
                                timeSlots[selectedMeridiemIndex.toString()]?[selectedTimeIndex[selectedMeridiemIndex.toString()] ?? 0].month ?? DateTime.now().month,
                                timeSlots[selectedMeridiemIndex.toString()]?[selectedTimeIndex[selectedMeridiemIndex.toString()] ?? 0].day ?? DateTime.now().day,
                                hour,
                                minute,
                              );

                              // Check if the slot time is reserved based on start and end times
                              bool isReserved = reservations.any((reservation) {
                                if (reservation.startTime.isBefore(reservation.endTime)) {
                                  DateTime reservationStartTime = DateTime.utc(
                                    reservation.startTime.year,
                                    reservation.startTime.month,
                                    reservation.startTime.day,
                                    reservation.startTime.hour,
                                    reservation.startTime.minute,
                                  );
                                  DateTime reservationEndTime = DateTime.utc(
                                    reservation.endTime.year,
                                    reservation.endTime.month,
                                    reservation.endTime.day,
                                    reservation.endTime.hour,
                                    reservation.endTime.minute,
                                  );

                                  bool overlaps = (slotTime.isAfter(reservationStartTime) && slotTime.isBefore(reservationEndTime)) ||
                                      (slotTime.isAtSameMomentAs(reservationStartTime) || slotTime.isAtSameMomentAs(reservationEndTime)) ||
                                      (reservationStartTime.isBefore(slotTime) && reservationEndTime.isAfter(slotTime)) ||
                                      (slotTime.isAtSameMomentAs(reservationStartTime)); // Include exact match for startTime

                                  // print('Is reserved: $overlaps');
                                  return overlaps;
                                }
                                return false; // Not a valid reservation
                              });

                              // Get the current time in UTC for comparison
                              DateTime now = DateTime.utc(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  DateTime.now().hour,
                                  DateTime.now().minute
                              );

                              // Check if the slot time is in the past
                              bool isPast = slotTime.isBefore(now);

                              if (!isPast) {
                                // print('Its not past because $slotTime is not before $now');
                              }

                              setState(() {
                                isAllowed = !isReserved && !isPast;
                              });

                              int slotsAvail = getAvailableSlots(slotTime, reservations as List<Reservation>);
                              print('Available slots for booking 2: $slotsAvail');

                              setState(() {
                                availableSlots = slotsAvail;
                              });
                            }).then((val) {
                              DateTime time = DateTime.now();
                              int adjustedHour = time.hour; // Get the current hour
                              int adjustedMinute = time.minute; // Get the current minute

                              print('Current time: $time');


                              // Round to the nearest 30 minutes
                              if (adjustedMinute < 30) {
                                adjustedMinute = 30; // Set to 30 minutes
                              } else {
                                adjustedMinute = 0; // Set to 0 minutes
                                adjustedHour += 1; // Move to the next hour
                                if (adjustedHour == 24) {
                                  adjustedHour = 0; // If it goes past midnight, set to 0
                                }
                              }

                              // Find the first time slot matching the adjusted hour and minute
                              var matchingSlot = timeSlots[selectedMeridiemIndex.toString()]?.firstWhereOrNull(
                                      (slot) => slot.hour == adjustedHour && slot.minute == adjustedMinute
                              );

                              if (matchingSlot != null) {
                                int? index = timeSlots[selectedMeridiemIndex.toString()]?.indexOf(matchingSlot);

                                WidgetsBinding.instance.addPostFrameCallback((_) async {
                                  _timeController.animateToItem(index ?? 0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut);
                                });
                              } else {
                                print('No matching time slot found for hour: $adjustedHour and minute: $adjustedMinute');
                              }
                            });
                          },
                          controller: _meridiemController,
                          enableAnimation: true,
                          allowPointerTappable: true,
                          hapticFeedbackType: HapticFeedbackType.vibrate,
                          showPointer: false,
                          itemSize: screenHeight * 0.045,
                          verticalListWidth: screenWidth * 0.22,
                          horizontal: false,
                          children: meridiemIndicator.asMap().entries.map((entry) {
                            final index = entry.key;
                            final period = entry.value;

                            return InkWell(
                              onTap: () {
                                WidgetsBinding.instance.addPostFrameCallback((_) async {
                                  _meridiemController.animateToItem(index,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut);
                                });
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  period,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: screenWidth * 0.05,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.1,
                        bottom: screenHeight * 0.1,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Container(
                            width: screenWidth * 0.03,
                            height: screenHeight * 0.03,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: screenWidth,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.015
                ),
                margin: EdgeInsets.only(bottom: screenHeight * 0.025),
                child: ElevatedButton(
                  onPressed: isAllowed ? () {
                    selectedSlotStatus = {
                      'selectedTimeIndex': selectedTimeIndex,
                      'selectedMeridiemIndex': selectedMeridiemIndex,
                      'slotTime': slotTime,
                      'availableSlots': availableSlots
                    };

                    Get.back(result: selectedSlotStatus);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.013
                    ),
                  ),
                  child: Text('Select ${formatSelectedTime(format: 'h:mm a')}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}