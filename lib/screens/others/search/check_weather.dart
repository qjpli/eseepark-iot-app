import 'package:eseepark/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class WeatherType {
  final int id;
  final String title;
  final String description;
  final String assetImg;

  WeatherType({
    required this.id,
    required this.title,
    required this.description,
    required this.assetImg,
  });
}

class CheckWeather extends StatefulWidget {
  const CheckWeather({super.key});

  @override
  State<CheckWeather> createState() => _CheckWeatherState();
}

class _CheckWeatherState extends State<CheckWeather> {
  String apiKey = 'e17ba97dd04f4b3991a104050251205';
  String locationName = '';
  String temperature = '';
  String condition = '';
  String iconUrl = '';
  WeatherType? weatherType;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchWeatherWithLocation();
  }

  WeatherType classifyWeather(String conditionText) {
    final lowerCondition = conditionText.toLowerCase();

    if (lowerCondition.contains('rain') ||
        lowerCondition.contains('showers') ||
        lowerCondition.contains('thunder')) {
      return WeatherType(
        id: 2,
        title: 'Raining? Find the Best Parking Spot',
        description:
        'It is currently raining. Consider using covered parking areas. Drive carefully, as roads and parking surfaces may be slippery.',
        assetImg: 'assets/images/weather/raining.png',
      );
    } else if (lowerCondition.contains('sunny') || lowerCondition.contains('clear')) {
      return WeatherType(
        id: 3,
        title: 'Sunny Day? Park Smart!',
        description:
        'It’s sunny outside. While parking under the sun might seem fine, remember prolonged exposure can heat your vehicle’s interior. Prefer shaded areas when possible.',
        assetImg: 'assets/images/weather/sunny.png',
      );
    } else {
      return WeatherType(
        id: 1,
        title: 'Rain Expected Today Plan Your Parking',
        description:
        'Rain is expected later today. Choosing a covered parking space can help protect your vehicle and keep you dry when you return.',
        assetImg: 'assets/images/weather/rain-expected.png',
      );
    }
  }

  Future<void> fetchWeatherWithLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final lat = position.latitude;
      final lon = position.longitude;

      final url =
          'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon&aqi=no';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Weather Condition: ${data['current']['condition']['text']}');
        setState(() {
          locationName =
          '${data['location']['name']}, ${data['location']['country']}';
          temperature = '${data['current']['temp_c']}°C';
          condition = data['current']['condition']['text'];
          iconUrl = 'https:${data['current']['condition']['icon']}';
          weatherType = classifyWeather(condition);
          isLoading = true;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch weather: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06
        ),
        height: screenHeight,
        alignment: Alignment.center,
        child: !isLoading
            ? CupertinoActivityIndicator(
          radius: screenSize * 0.02,
        )
            : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      weatherType?.title ?? '',
                      style: TextStyle(
                        fontSize: screenSize * 0.022,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    if (weatherType != null) ...[
                      Image.asset(
                        weatherType?.assetImg ?? '',
                        width: screenWidth * 0.9,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.cloud,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 5),
                      Text(
                        weatherType!.description,
                        style: TextStyle(
                            fontSize: screenSize * 0.012
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: screenHeight * 0.07
                  ),
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.063,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text('Okay, got it!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenSize * 0.011
                      ),
                    ),
                  ),
                ),
              ],
        ),
      ),
    );
  }
}
