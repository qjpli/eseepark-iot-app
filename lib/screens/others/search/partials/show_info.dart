import 'dart:convert';

import 'package:eseepark/controllers/establishments/establishments_controller.dart';
import 'package:eseepark/globals.dart';
import 'package:eseepark/main.dart';
import 'package:eseepark/models/profile_model.dart';
import 'package:eseepark/screens/others/search/partials/qr_generated_establishment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase/supabase.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/establishment_model.dart';
import '../../home/partials/parking_sheet.dart';

class ShowInfo extends StatefulWidget {
  final String establishmentId;
  final double? distance;

  const ShowInfo({
    super.key,
    required this.establishmentId,
    this.distance
  });

  @override
  State<ShowInfo> createState() => _ShowInfoState();
}

class _ShowInfoState extends State<ShowInfo> {
  final _controller = EstablishmentController();
  final ScrollController _scrollController = ScrollController();
  late final MapController _mapController;

  bool isNoSlotShown = false;

  List<dynamic>? favorites = supabase.auth.currentUser?.userMetadata?['favorite_establishments'];

  bool isFavorite = false;

  void initData() async {
    isFavorite = favorites != null && favorites!.contains(widget.establishmentId.toString());
  }


  bool isImageNotShown = false;

  String type = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _scrollController.addListener(_scrollListener);
    initData();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > screenHeight * 0.24) {
      if(!isImageNotShown) {
        setState(() {
          isImageNotShown = true;
        });
      }
    } else {
      if(isImageNotShown) {
        setState(() {
          isImageNotShown = false;
        });
      }
    }
  }


  String formatTime(String time) {
    try {
      final DateTime dateTime = DateFormat("HH:mm").parse(time);
      return DateFormat("h:mm a").format(dateTime);
    } catch (e) {
      return time;
    }
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: StreamBuilder(
          stream: _controller.getEstablishmentById(widget.establishmentId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Error found: ${snapshot.error}');
              return Center(child: Text("Error loading data: ${snapshot.error}"));
            }

            final establishment = snapshot.data;

            if (establishment == null) {
              return Center(
                key: ValueKey<String>('loading'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CupertinoActivityIndicator(
                      radius: screenWidth * 0.05,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text('Loading\nEstablishment...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: screenSize * 0.01,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                      ),
                    )
                  ],
                ),
              );
            }

            // Delay the move call until after the frame is built
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _mapController.move(
                  LatLng(establishment.coordinates['lat'], establishment.coordinates['lng']),
                  16,
                );
              }
            });

            if((establishment.parkingSections?.fold<int>(0, (sum, section) => sum + (section.parkingSlots?.where((slot) => slot.slotStatus == 'available').length ?? 0)) ?? 0) == 0) {


              if(!isNoSlotShown) {
                isNoSlotShown = true;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {

                    print('No slots available: $isNoSlotShown');

                    if (!Get.isSnackbarOpen) { // Prevent multiple snackbars
                      Get.snackbar(
                        'No Slots Available',
                        'Sorry, there are no slots available at this time.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.shade600,
                        colorText: Colors.white,
                        margin: EdgeInsets.only(
                            bottom: screenHeight * 0.1,
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05
                        ),
                        duration: Duration(days: 1), // Keeps the Snackbar visible indefinitely
                        isDismissible: false,
                        overlayBlur: 0.0, // Prevents Snackbar from being an overlay
                        overlayColor: Colors.transparent,
                        animationDuration: Duration(milliseconds: 500)
                      );

                    }
                  }
                });
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                });
              }
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if(mounted) {
                  if(isNoSlotShown || Get.isSnackbarOpen) {
                    Get.closeAllSnackbars();
                    isNoSlotShown = false;
                  }
                }
              });
            }

            return Stack(
              key: ValueKey<String>('showInfo'),
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  controller: _scrollController,
                  children: [
                    Container(
                      height: screenHeight * 0.33,
                      width: screenWidth,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          image: establishment.image != null ? DecorationImage(
                              image: NetworkImage(establishment.image.toString()),
                              fit: BoxFit.cover
                          ) :
                          DecorationImage(
                              image: AssetImage('assets/images/general/eseepark-transparent-logo-768.png'),
                              scale: 6,
                              alignment: Alignment.center
                          ),
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(10)
                          )
                      ),
                    ),
                    Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                          color: Colors.white
                      ),
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(

                                ),
                                child: Wrap(
                                  spacing: screenWidth * 0.02,
                                  children: (establishment.supportedVehicleTypes ?? []).asMap().entries.map((entry) {
                                    final vehicleType = entry.value;
                                    return Container(
                                      margin: EdgeInsets.only(right: screenWidth * 0.01),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Theme.of(context).colorScheme.primary
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.03,
                                          vertical: screenWidth * 0.01
                                      ),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset('assets/svgs/search/${entry.value.toLowerCase()}.svg',
                                            width: screenWidth * 0.04,
                                            colorFilter: ColorFilter.mode(
                                                Colors.white,
                                                BlendMode.srcIn
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.02),
                                          Text(vehicleType.toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: screenWidth * 0.026
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              Container(
                                width: screenWidth * 0.92,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(establishment.name.toString(),
                                        maxLines: 2,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.05,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                    Container(
                                      margin: EdgeInsets.only(top: screenHeight * 0.0045),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.star,
                                            color: Theme.of(context).colorScheme.primary,
                                            size: screenWidth * 0.04,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          Text(establishment.feedbacksTotalRating.toString(),
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.w600
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Container(
                                width: screenWidth * 0.92,
                                child: Text(establishment.address.toString(),
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)
                                  ),
                                ),
                              ),
                              if(widget.distance != null)
                                Container(
                                    width: screenWidth * 0.92,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(
                                        top: screenHeight * 0.01
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.location_pin, size: screenWidth * 0.034),
                                          SizedBox(width: screenWidth * 0.01),
                                          Padding(
                                            padding: EdgeInsets.only(top: screenHeight * 0.0025),
                                            child: Text('${(widget.distance ?? 0).toStringAsPrecision(2)} km away',
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.03
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                ),

                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                          color: Colors.white
                      ),
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
                      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Some things to note',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: (establishment.parkingRate?.rateType ?? '') == 'tiered_hourly' ? 'Hourly Rate' : 'Flat Rate',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.033,
                                    fontWeight: FontWeight.w600,
                                  )
                                ),
                                TextSpan(
                                  text: '  •  ',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.03
                                  ),
                                ),
                                if(establishment.parkingRate?.rateType == 'tiered_hourly')
                                  TextSpan(
                                      children: [
                                        TextSpan(
                                            text: '₱${establishment.parkingRate?.baseRate}'
                                        ),
                                        TextSpan(
                                            text: ' first ',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                            )
                                        ),
                                        TextSpan(
                                            text: '${establishment.parkingRate?.baseHours}'
                                        ),
                                        TextSpan(
                                            text: ' hours, then ',
                                            style: TextStyle(
                                                fontFamily: 'Poppins'
                                            )
                                        ),
                                        TextSpan(
                                            text: '₱${establishment.parkingRate?.extraHourlyRate}',
                                        ),
                                        TextSpan(
                                            text: ' per hour',
                                            style: TextStyle(
                                                fontFamily: 'Poppins'
                                            )
                                        )
                                      ],
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.033,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'HelveticaNeue'
                                      )
                                  ),
                                if(establishment.parkingRate?.rateType == 'flat_rate')
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '₱${establishment.parkingRate?.flatRate}',
                                        style: TextStyle(
                                          fontFamily: 'HelveticaNeue',
                                          fontSize: screenWidth * 0.033,
                                        )
                                      ),
                                      TextSpan(
                                          text: ' Fixed Rate',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: screenWidth * 0.033,
                                          )
                                      )
                                    ],
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.w400,
                                    )
                                  )
                              ],
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Theme.of(context).colorScheme.primary
                              )
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(3)
                                ),
                                padding: EdgeInsets.all(screenWidth * 0.005),
                                child: Icon(Icons.local_parking, color: Colors.white, size: screenWidth * 0.03),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text((establishment.parkingSections?.fold<int>(0, (sum, section) => sum + (section.parkingSlots?.where((slot) => slot.slotStatus == 'available').length ?? 0)) ?? 0) == 0 ?
                              'No slots available' :
                              '${establishment.parkingSections?.fold<int>(0, (sum, section) => sum + (section.parkingSlots?.where((slot) => slot.slotStatus == 'available').length ?? 0)) ?? 0} out of ${establishment.parkingSections?.fold<int>(0, (sum, section) => sum + (section.parkingSlots?.length ?? 0)) ?? 0} slots are available',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.033,
                                  height: 1.1,
                                  color: (establishment.parkingSections?.fold<int>(0, (sum, section) => sum + (section.parkingSlots?.where((slot) => slot.slotStatus == 'available').length ?? 0)) ?? 0) == 0 ?
                                      Colors.red : (establishment.parkingSections?.fold<int>(0, (sum, section) => sum + (section.parkingSlots?.where((slot) => slot.slotStatus == 'available').length ?? 0)) ?? 0) == 1 ?
                                      Colors.orange.shade600 :
                                      Theme.of(context).colorScheme.primary
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Divider(
                            height: screenHeight * 0.015,
                            thickness: 0.2,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Contact Number',
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.005),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary,
                                              borderRadius: BorderRadius.circular(3)
                                          ),
                                          padding: EdgeInsets.all(screenWidth * 0.005),
                                          child: Icon(Icons.phone, color: Colors.white, size: screenWidth * 0.03),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Text(establishment.contactNumber ?? '',
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.033,
                                              height: 1.1
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Establishment Type',
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.005),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary,
                                              borderRadius: BorderRadius.circular(3)
                                          ),
                                          padding: EdgeInsets.all(screenWidth * 0.005),
                                          child: Icon(Icons.bloodtype, color: Colors.white, size: screenWidth * 0.03),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Text(establishment.establishmentType ?? '',
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.033,
                                              height: 1.1
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Operating Hours',
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Wrap(
                                  spacing: screenWidth * 0.024,
                                  runSpacing: screenHeight * 0.011,
                                  children: establishment.operatingHours.asMap().entries.map((entry) {
                                    final operatingHour = entry.value;

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02,
                                          vertical: screenHeight * 0.005
                                      ),
                                      child: Column(
                                        children: [
                                          Text(formatTime(operatingHour.open),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: screenWidth * 0.025,
                                                fontWeight: FontWeight.w400
                                            ),
                                          ),
                                          Text(operatingHour.day,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: screenWidth * 0.034,
                                                letterSpacing: 1,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),
                                          Text(formatTime(operatingHour.close),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: screenWidth * 0.025,
                                                fontWeight: FontWeight.w400
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                    Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                          color: Colors.white
                      ),
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
                      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Feedback and Ratings',
                            style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)
                            ),
                          ),
                          FutureBuilder<ProfileModel>(
                              future: _controller.getProfile(establishment.feedbacks!.first.userId),
                              builder: (context, snapshot) {

                                if(snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                final ProfileModel? profile = snapshot.data;

                                return Container(
                                  child: (establishment.feedbacks ?? []).isNotEmpty ?
                                  Padding(
                                    padding: EdgeInsets.only(top: screenHeight * 0.01),
                                    child: Container(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.account_circle_rounded,
                                            color: Theme.of(context).colorScheme.primary,
                                            size: screenWidth * 0.12,
                                          ),
                                          SizedBox(width: screenWidth * 0.02),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start, // Align text properly
                                            children: [
                                              Container(
                                                width: screenWidth * 0.76,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(profile?.name.toString() ?? '',
                                                          style: TextStyle(
                                                              fontSize: screenWidth * 0.037,
                                                              fontWeight: FontWeight.bold
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            ...List.generate(
                                                              (establishment.feedbacks!.first.rating ?? 0.0).floor(),
                                                                  (index) => Icon(
                                                                Icons.star,
                                                                size: screenSize * 0.014,
                                                                color: Theme.of(context).colorScheme.primary,
                                                              ),
                                                            ),
                                                            if ((establishment.feedbacks!.first.rating ?? 0.0) % 1 != 0) // ✅ Fix parentheses placement
                                                              Icon(
                                                                Icons.star_half_rounded,
                                                                size: screenSize * 0.014,
                                                                color: Theme.of(context).colorScheme.primary,
                                                              ),
                                                            SizedBox(width: screenWidth * 0.01),
                                                            Text(
                                                              establishment.feedbacks!.first.rating.toString(),
                                                              style: TextStyle(
                                                                  fontSize: screenWidth * 0.033,
                                                                  fontWeight: FontWeight.bold
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Text(DateFormat('MMM d, y').format(establishment.feedbacks!.first.createdAt),
                                                      style: TextStyle(
                                                          fontSize: screenWidth * 0.03
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: screenHeight * 0.01),
                                              Container(
                                                width: screenWidth * 0.76,
                                                child: Text(establishment.feedbacks!.first.comment ?? '',
                                                  style: TextStyle(
                                                      fontSize: screenWidth * 0.033
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ) : SizedBox.shrink(),
                                );
                              }
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          InkWell(
                            onTap: () {
                              print('Feedbacks');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: screenHeight * 0.003),
                                  child: Icon(
                                    Icons.feedback,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: screenWidth * 0.045,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text('See All Feedbacks (${establishment.feedbacks?.length ?? 0})',
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.034,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      height: 1
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                          color: Colors.white
                      ),
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
                      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Where to Find Us',
                            style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Stack(
                            children: [
                              Container(
                                height: screenHeight * 0.3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      interactionOptions: InteractionOptions(
                                        debugMultiFingerGestureWinner: false,
                                        flags: InteractiveFlag.none
                                      ),
                                      keepAlive: true,
                                        onTap: (TapPosition position, LatLng latLng) async {
                                          print('opened');
                                          final double lat = establishment.coordinates['lat'];
                                          final double lng = establishment.coordinates['lng'];

                                          final Uri googleMapsUri = Uri.parse('comgooglemaps://?daddr=$lat,$lng&directionsmode=driving');
                                          final Uri webUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

                                          if (await canLaunchUrl(googleMapsUri)) {
                                            await launchUrl(googleMapsUri);
                                          } else {
                                            await launchUrl(webUri); // Fallback to web if the app is not installed
                                          }
                                        },
                                      onMapEvent: (MapEvent event) {
                                        print('Event: $event');
                                      },
                                      onMapReady: () {
                                        Future.delayed(Duration(milliseconds: 500), () {
                                          print('Type: $type');
                                          setState(() {
                                            type = 'https://api.maptiler.com/maps/basic-v2/{z}/{x}/{y}.png?key=Qipsk8ow5i3XD55aV9F0';
                                          });
                                        });
                                      }
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate: type,
                                        userAgentPackageName: 'com.eseepark.eseepark',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            width: 100,
                                            height: 100,
                                            point: LatLng(establishment.coordinates['lat'], establishment.coordinates['lng']), // Location for the marker
                                            child: Icon(Icons.location_on, color: Colors.red.shade600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: InkWell(
                                  onTap: ()  async {
                                    print('Latitude: ${establishment.coordinates['lat']}');
                                    print('Longitude: ${establishment.coordinates['lng']}');

                                    final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${establishment.coordinates['lat']},${establishment.coordinates['lng']}');

                                    if (!await launchUrl(url)) {
                                     throw 'Could not launch $url';
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                                    ),
                                    padding: EdgeInsets.only(
                                        left: screenWidth * 0.05,
                                        right: screenWidth * 0.05,
                                        top: screenHeight * 0.05,
                                        bottom: screenHeight * 0.04,
                                    ),
                                    child: Text('Click on the map to navigate to the establishment location',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.12),
                  ],
                ),
                if (establishment.operatingHours.any((operatingHour) =>
                operatingHour.day == getFormattedWeekday(DateTime.now().weekday)))
                  Positioned(
                  bottom: screenHeight * 0.04,
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  child: InkWell(
                    onTap: establishment.operatingHours.any((operatingHour) =>
                    int.parse(getFormattedTime(operatingHour.open)) <= DateTime.now().hour &&
                        int.parse(getFormattedTime(operatingHour.close)) > DateTime.now().hour) ? () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return ParkingSheet(establishmentId: establishment.establishmentId, distance: widget.distance);
                      });
                    } : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.06,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: establishment.operatingHours.any((operatingHour) =>
            int.parse(getFormattedTime(operatingHour.open)) <= DateTime.now().hour &&
            int.parse(getFormattedTime(operatingHour.close)) > DateTime.now().hour) ? Theme.of(context).colorScheme.primary  : Colors.grey.shade500.withValues(alpha: 0.6)
                      ),
                      alignment: Alignment.center,
                      child: Text(establishment.operatingHours.any((operatingHour) =>
                          int.parse(getFormattedTime(operatingHour.open)) <= DateTime.now().hour &&
                          int.parse(getFormattedTime(operatingHour.close)) > DateTime.now().hour) ? 'Explore' : 'Closed now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600
                        ),
                      )
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.065,
                  left: screenWidth * 0.05,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: () {
                      if(Get.isSnackbarOpen) {
                        Get.closeAllSnackbars();
                      }

                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: !isImageNotShown ? Colors.white : Theme.of(context).colorScheme.primary,
                        border: Border.all(
                          color: !isImageNotShown ? Colors.white : Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.01),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Icon(
                          Icons.arrow_back_outlined,
                          key: ValueKey<bool>(isImageNotShown), // Ensures animation triggers on state change
                          color: !isImageNotShown ? Theme.of(context).colorScheme.primary : Colors.white,
                        ),
                      ),
                    ),
                  ),

                ),
                Positioned(
                  top: screenHeight * 0.065,
                  right: screenWidth * 0.05,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () async {

                          final data = {
                            "purpose": "establishment-redirect",
                            "data": {
                              "id": establishment.establishmentId
                            }
                          };
                          final json = jsonEncode(data);

                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              enableDrag: true,
                              builder: (context) {
                                return QRGeneratedEstablishment(qrData: json, establishment: establishment);
                              }
                          );

                          print('generated');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          padding: EdgeInsets.all(screenWidth * 0.015),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.qr_code,
                            color: Theme.of(context).colorScheme.primary
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      InkWell(
                        onTap: () async {
                          final user = supabase.auth.currentUser;
                          if (user == null) return;

                          List<String> favoriteEstablishments = (user.userMetadata?['favorite_establishments'] as List<dynamic>?)
                              ?.map((e) => e.toString())
                              .toList() ?? [];

                          if (favoriteEstablishments.contains(establishment.establishmentId)) {
                            favoriteEstablishments.remove(establishment.establishmentId);
                          } else {
                            favoriteEstablishments.add(establishment.establishmentId);
                          }

                          await supabase.auth.updateUser(
                            UserAttributes(
                              data: {'favorite_establishments': favoriteEstablishments},
                            ),
                          );

                          setState(() {}); // If using StatefulWidget
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          padding: EdgeInsets.all(screenWidth * 0.015),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.favorite,
                            color: supabase.auth.currentUser?.userMetadata?['favorite_establishments'] != null && supabase.auth.currentUser?.userMetadata?['favorite_establishments'].contains(establishment.establishmentId) ? Colors.red : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }
        ),
      ),
    );
  }
}
