import 'dart:async';
import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:eseepark/customs/custom_widgets.dart';
import 'package:eseepark/models/establishment_model.dart';
import 'package:eseepark/models/parking_slot_model.dart';
import 'package:eseepark/screens/others/booking/booking.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../controllers/establishments/establishments_controller.dart';
import '../../../../globals.dart';
import '../../../../models/parking_section_model.dart';


class Section {
  final int id;
  final String section;

  const Section({
    required this.id,
    required this.section
  });
}

class Slot {
  final int id;
  final Section slotSection;
  final int slotNo;
  final String slotStatus;
  int? timeOccupied;

  Slot({
    required this.id,
    required this.slotSection,
    required this.slotNo,
    required this.slotStatus,
    this.timeOccupied
  });

  void incrementTime() {
    if (slotStatus == 'Occupied' && timeOccupied != null) {
      timeOccupied = timeOccupied! + 1; // Increment time by 1 second
    }
  }
}

class ParkingSheet extends StatefulWidget {
  final String establishmentId;
  final double? distance;

  const ParkingSheet({
    super.key,
    required this.establishmentId,
    this.distance
  });

  @override
  State<ParkingSheet> createState() => _ParkingSheetState();
}

class _ParkingSheetState extends State<ParkingSheet> {
  final _controller = EstablishmentController();
  int floorIndex = -1;
  late Timer _timer;

  String selectedSlot = '';

  List<Section> sectionList = [
    Section(id: 1, section: 'A'),
    Section(id: 2, section: 'B'),
    Section(id: 3, section: 'C'),
  ];

  List<Slot> slots = [];

  List<Slot> generateSlots() {
    List<Slot> slots = [];
    Random random = Random();

    for (var section in sectionList) {
      for (int i = 1; i <= 5; i++) {
        bool isOccupied = random.nextBool();
        slots.add(Slot(
          id: (section.id - 1) * 5 + i,
          slotSection: section,
          slotNo: i,
          slotStatus: isOccupied ? 'Occupied' : 'Available',
          timeOccupied: isOccupied ? random.nextInt(120) + 1 : null, // 1 to 120 minutes
        ));
      }
    }
    return slots;
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        for (var slot in slots) {
          slot.incrementTime();
        }
      });
    });
  }


  @override
  void initState() {
    super.initState();

    slots = generateSlots();
    startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _timer.cancel();
  }

  final List<String> items = [
    'All',
    'Free',
    'Occupied',
    'Reserved'
  ];

  String selectedValue = 'All';
  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: _controller.getEstablishmentById(widget.establishmentId),
      builder: (context, snapshot) {

      if (snapshot.hasError) {
        print('Error found: ${snapshot.error}');
        return Center(child: Text("Error loading data: ${snapshot.error}"));
      }

      final establishment = snapshot.data;


      if (establishment == null) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFFEAEAEA),
          highlightColor: const Color(0xFFEAEAEA).withOpacity(0.4),
          enabled: true,
          direction: ShimmerDirection.ltr,
          child: Container(
            height: screenHeight * 0.83,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.035,
                          horizontal: screenWidth * 0.04
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: screenHeight * 0.028,
                                    width: screenWidth * 0.5,
                                    margin: EdgeInsets.only(bottom: screenHeight * 0.01),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Color(0xffeaeaea)
                                    ),
                                  ),
                                  Container(
                                    height: screenHeight * 0.02,
                                    width: screenWidth * 0.3,
                                    margin: EdgeInsets.only(bottom: screenHeight * 0.01),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Color(0xffeaeaea)
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Color(0xffeaeaea),
                                shape: BoxShape.circle
                            ),
                            padding: EdgeInsets.all(screenSize * 0.013),
                            child: Icon(Icons.close),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: screenHeight * 0.061,
                            width: screenWidth * 0.3,
                            margin: EdgeInsets.only(right: screenWidth * 0.03),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color(0xffeaeaea)
                            ),
                          ),
                          Container(
                            height: screenHeight * 0.061,
                            width: screenWidth * 0.3,
                            margin: EdgeInsets.only(right: screenWidth * 0.03),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color(0xffeaeaea)
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: screenWidth,
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.025
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              height: screenHeight * 0.027,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color(0xffeaeaea)
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.1),
                          Container(
                            height: screenHeight * 0.061,
                            width: screenWidth * 0.3,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color(0xffeaeaea)
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: screenWidth,
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.025
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              height: screenHeight * 0.085,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Color(0xffeaeaea)
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.09),
                          Expanded(
                            child: Container(
                              height: screenHeight * 0.085,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Color(0xffeaeaea)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: screenWidth,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              height: screenHeight * 0.085,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Color(0xffeaeaea)
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.09),
                          Expanded(
                            child: Container(
                              height: screenHeight * 0.085,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Color(0xffeaeaea)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.04,
                      right: screenWidth * 0.04,
                      bottom: screenHeight * 0.04
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                          height: screenHeight * 0.07,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Color(0xffeaeaea)
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.07),
                      Expanded(
                        child: Container(
                          height: screenHeight * 0.07,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Color(0xffeaeaea)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

        return Container(
          height: screenHeight * 0.83,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.04
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(establishment.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenSize * 0.018,

                            ),),
                            Text('Slots Available: ${establishment.parkingSections
                                ?.fold<int>(0, (sum, section) => sum + (section.parkingSlots?.where((slot) => slot.slotStatus == 'available').length ?? 0)) ?? 0}',
                            style: TextStyle(
                              color: (establishment.parkingSections
                                  ?.fold<int>(0, (sum, section) => sum + (section.parkingSlots?.where((slot) => slot.slotStatus == 'available').length ?? 0)) ?? 0) == 0 ? Colors.red : Color(0xff808080),
                              fontSize: screenSize * 0.01
                            ),)
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xffcacaca)
                          ),
                          shape: BoxShape.circle
                        ),
                        padding: EdgeInsets.all(screenSize * 0.01),
                        child: Icon(Icons.close),
                      ),
                    )
                  ],
                ),
              ), // MALL NAME, SLOTS, N BUTTON
              Container(
                height: screenHeight * 0.05,
                width: screenWidth,
                child: ListView.builder(
                  itemCount: (establishment.parkingSections?.fold(0, (val, section) =>
                  (section.floorLevel ?? 0) > (val ?? 0) ? val = (section.floorLevel ?? 0) : val) ?? 0) + 1,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    bool isAllSelected = floorIndex == -1;
                    bool isCurrentFloor = floorIndex == index - 1;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          floorIndex = index == 0 ? -1 : index - 1;
                        });

                        print(floorIndex);
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      child: Container(
                        decoration: BoxDecoration(
                          color: index == 0
                              ? (isAllSelected ? Theme.of(context).colorScheme.primary : Color(0xffd9d9d9))
                              : (isCurrentFloor ? Theme.of(context).colorScheme.primary : Color(0xffd9d9d9)),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        margin: EdgeInsets.only(
                            left: index == 0 ? screenWidth * 0.03 : screenWidth * 0.045
                        ),
                        child: Text(
                          index == 0 ? 'All' : 'Floor ${index}', // First button is "All"
                          style: TextStyle(
                            color: index == 0
                                ? (isAllSelected ? Colors.white : Color(0xff545454))
                                : (isCurrentFloor ? Colors.white : Color(0xff545454)),
                            fontWeight: index == 0
                                ? (isAllSelected ? FontWeight.bold : FontWeight.normal)
                                : (isCurrentFloor ? FontWeight.bold : FontWeight.normal),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text('Showing Details for ${floorIndex == -1 ? 'All' : 'Floor ${floorIndex + 1}'}',
                        style: TextStyle(
                            color: Color(0xff808080)
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Select Item',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: items
                              .map((String item) => DropdownMenuItem<String>(
                            value: item,
                            enabled: true,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: selectedValue == item ? Colors.transparent : Colors.white
                              ),
                              child: Text(
                                item,
                                style: TextStyle(
                                    fontSize: screenSize * 0.012,
                                    fontWeight: selectedValue == item ? FontWeight.bold : FontWeight.normal,
                                    color: selectedValue == item ? Theme.of(context).colorScheme.primary : Colors.black
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ))
                              .toList(),
                          value: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value!;
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: 200,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                              color: Colors.transparent,
                            ),
                            elevation: 0,
                          ),
                          iconStyleData: IconStyleData(
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            iconSize: 14,
                            iconEnabledColor: Theme.of(context).colorScheme.primary,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 300,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    width: .5,
                                    color: const Color(0xFFD1D1D1)
                                )
                            ),
                            elevation: 0,
                            offset: const Offset(-110, -10),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: MaterialStateProperty.all(6),
                              thumbVisibility: MaterialStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            selectedMenuItemBuilder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.015,
                                    horizontal: screenWidth * 0.03
                                ),
                                child: Text(selectedValue,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenSize * 0.012
                                  ),
                                ),
                              );
                            },
                            padding: const EdgeInsets.only(left: 14, right: 14),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: GridView.builder(
                    itemCount: establishment.parkingSections
                        ?.where((section) => floorIndex == -1 || section.floorLevel == floorIndex + 1)
                        .expand((section) => section.parkingSlots?.where((slot) {
                      bool isSorted = selectedValue == 'All'
                          ? true
                          : slot.slotStatus == (selectedValue == 'Free' ? 'available' : selectedValue.toLowerCase());
                      return isSorted;
                    }).toList() ?? [])
                        .length ?? 0,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 14,
                      childAspectRatio: 2.4,
                    ),
                    itemBuilder: (context, index) {
                      final List<Map<String, dynamic>> allSlots = (establishment.parkingSections
                          ?.where((section) => floorIndex == -1 || section.floorLevel == floorIndex + 1)
                          .expand((section) => section.parkingSlots
                          ?.where((slot) {
                        bool isSorted = selectedValue == 'All'
                            ? true
                            : slot.slotStatus == (selectedValue == 'Free' ? 'available' : selectedValue.toLowerCase());
                        return isSorted;
                      })
                          .map((slot) => {'sectionName': section.name, 'slotNumber': slot.slotNumber, 'slot': slot})
                          .toList() ?? <Map<String, dynamic>>[])
                          .toList() ?? <Map<String, dynamic>>[])
                          .cast<Map<String, dynamic>>();

                      if (index >= allSlots.length) return SizedBox();

                      // ✅ Get section name and slot number
                      final String sectionName = allSlots[index]['sectionName'] as String;
                      final int slotNumber = allSlots[index]['slotNumber'] as int;
                      final ParkingSlot currentSlot = allSlots[index]['slot'] as ParkingSlot;

                      return InkWell(
                        onTap: currentSlot.slotStatus == 'available'
                            ? () {
                          setState(() {
                            selectedSlot = currentSlot.id != selectedSlot ? currentSlot.id : '';
                          });
                        }
                            : null,
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          decoration: BoxDecoration(
                            border: currentSlot.slotStatus == 'available'
                                ? Border.all(
                                  width: 2,
                                  color: currentSlot.id == selectedSlot ? Theme.of(context).colorScheme.primary : const Color(0xFFD1D1D1),
                                ) : currentSlot.slotStatus == 'reserved' ? Border.all(
                                  width: 2,
                                  color: Colors.yellow
                                ) : null,
                            color: currentSlot.slotStatus == 'available' ? currentSlot.id == selectedSlot
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent
                                : currentSlot.slotStatus == 'reserved' ? Colors.yellow.withValues(alpha: 0.3) : Theme.of(context).colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '$sectionName-$slotNumber',
                                style: TextStyle(
                                  fontSize: screenSize * 0.015,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                  color: currentSlot.slotStatus == 'available' || currentSlot.slotStatus == 'reserved' ? Colors.black : Colors.white,
                                ),
                              ),
                              if (currentSlot.slotStatus != 'Under Maintenance' && currentSlot.slotStatus != 'reserved')
                                ParkingSlotTimer(slotStatus: currentSlot.slotStatus, timeTaken: currentSlot.timeTaken?.toString()),
                              if (currentSlot.slotStatus == 'reserved')
                                Text(
                                  'Reserved',
                                  style: TextStyle(
                                    fontSize: screenSize * 0.0095,
                                    height: 1.3,
                                    color: Colors.black.withValues(alpha: 0.3)
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if(false)
                Container(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.03,
                    bottom: screenHeight * 0.03,
                    left: screenWidth * 0.05,
                    right: screenWidth * 0.05
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedSlot.isNotEmpty ? () {
                            final checkSlotAvailability = establishment.parkingSections?.firstWhere(
                                (section) => section.parkingSlots?.any((slot) => slot.id == selectedSlot) ?? false
                            );

                            print('clicked');

                            if (checkSlotAvailability?.parkingSlots?.firstWhere((slot) => slot.id == selectedSlot).slotStatus != 'available') {

                              Get.snackbar(
                                'Oops!',
                                'Sorry, this slot is not available at the moment.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                borderRadius: 10,
                                margin: EdgeInsets.all(10),
                                duration: const Duration(seconds: 3),
                              );

                              setState(() {
                                selectedSlot = '';
                              });

                              return;
                            } else {
                              print('happening');
                              Get.back();
                              Get.to(() => Booking(slotId: selectedSlot, distance: widget.distance, availableSlots: (establishment.parkingSections
                                  ?.fold<int>(0, (sum, section) => sum + (section.parkingSlots?.where((slot) => slot.slotStatus == 'available').length ?? 0)) ?? 0)),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 300),
                              );
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.017
                            )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(selectedSlot.isEmpty
                                  ? 'Choose a Slot'
                                  : 'Pick Slot ${establishment.parkingSections?.firstWhere(
                                      (sec) => sec.parkingSlots?.any((slot) => slot.id == selectedSlot) ?? false
                              ).name} - ${establishment.parkingSections?.firstWhere(
                                      (sec) => sec.parkingSlots?.any((slot) => slot.id == selectedSlot) ?? false
                              ).parkingSlots?.firstWhere((slot) => slot.id == selectedSlot).slotNumber}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenSize * 0.014,
                                  fontWeight: FontWeight.w600
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                )
            ],
          ),
        );
      },
    );
  }
}
