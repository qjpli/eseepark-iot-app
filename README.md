# eSEEPark

## A Smart Parking Companion

eSEEPark is an innovative parking solution designed to help drivers locate available parking spots in real time. It integrates IoT technology with cloud computing to provide a seamless parking experience for both users and parking administrators. 

## Technologies Used
- **Flutter & Dart** – Cross-platform mobile app development.
- **IoT (ESP32, Arduino, HC-SR04 sensors, LED indicators, Servo motor)** – Monitors parking slot occupancy and automates entry/exit gates.
- **Cloud Computing (Supabase)** – Handles database management and authentication.

## Features
✅ **Real-time Parking Slot Availability** – View available, occupied, and under-maintenance slots.
✅ **Slot Filtering** – Filter by PWD, EV charging, covered parking, etc.
✅ **QR Code System** – Scan at the entrance for quick access to parking info.
✅ **Reservation System** – Reserve slots in advance and validate via QR code.
✅ **Favorite Parking Locations** – Save frequently visited parking areas.
✅ **Occupied Slot Timer** – Tracks how long a slot has been occupied.
✅ **Parking History** – View and export past bookings and payments.

## Installation Instructions
1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/eseepark.git
   cd eseepark
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the application:
   ```sh
   flutter run
   ```

## Setup
### IoT Device Setup
- Connect **HC-SR04 ultrasonic sensors** to **ESP32** to detect car presence.
- Integrate **LED indicators** to show slot status.
- Use **Servo motors** for entry/exit gate automation.
- Program the ESP32 using **Arduino IDE** or **PlatformIO**.

### Cloud Setup (Supabase)
1. Create a **Supabase** account and project.
2. Set up database tables for parking slots, reservations, and user authentication.
3. Configure API keys and environment variables in Flutter.

## Contribution
Feel free to contribute by submitting pull requests or opening issues.

---

For any inquiries, contact us at **[your email or website]** 🚗💨
