import 'package:eseepark/models/vehicle_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../globals.dart';

class VehiclePicker extends StatefulWidget {
  final List<Vehicle> items;
  final String title;
  final String? titleKey;
  final Vehicle? selectedVehicle;

  const VehiclePicker({
    super.key,
    required this.items,
    this.titleKey,
    required this.title,
    this.selectedVehicle
  });

  @override
  State<VehiclePicker> createState() => _VehiclePickerState();
}

class _VehiclePickerState extends State<VehiclePicker> {
  Vehicle? selectedItem;
  Map<String, dynamic>? mapData;

  @override
  void initState() {
    super.initState();

    if(widget.selectedVehicle != null) {
      selectedItem = widget.selectedVehicle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Text(widget.title,
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
        Container(
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: widget.items.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    if(widget.items[index] != selectedItem) {
                      setState(() {
                        selectedItem = widget.items[index];
                        mapData = {
                          'value': widget.items[index],
                          'id': index
                        };
                      });
                    } else {
                      setState(() {
                        selectedItem = null;
                      });
                    }
                  },
                  leading: Checkbox(
                    value: widget.items[index] == selectedItem,
                    onChanged: (selected) {
                      if(widget.items[index] != selectedItem) {
                        setState(() {
                          selectedItem = widget.items[index];
                        });
                      } else {
                        setState(() {
                          selectedItem = null;
                        });
                      }
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    visualDensity: VisualDensity.comfortable,
                    focusColor: Colors.white,
                  ),
                  title: Text(widget.items[index].name,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                );
              }
          ),
        ),
        Container(
          width: screenWidth,
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.015
          ),
          margin: EdgeInsets.only(bottom: screenHeight * 0.025),
          child: ElevatedButton(
            onPressed: selectedItem == null ? null : () => Get.back(result: selectedItem),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.013
              ),
            ),
            child: Text('Select',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600
              ),
            ),
          ),
        )
      ],
    );
  }
}